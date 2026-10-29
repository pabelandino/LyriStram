function normalizeSdpLineEndings(sdp: string): string {
  return sdp.includes('\r\n') ? sdp : sdp.replace(/\n/g, '\r\n');
}

/** Prefer H.264 payload order in SDP (signaling only — do not pass through setLocalDescription). */
export function preferH264InSdp(sdp: string): string {
  const normalized = normalizeSdpLineEndings(sdp).trim();
  if (!normalized) {
    return sdp;
  }

  const sections = normalized.split(/\r\nm=/);
  if (sections.length <= 1) {
    return normalized;
  }

  const head = sections[0] ?? '';
  const mediaSections = sections.slice(1).map((section) => `m=${section}`);

  const reordered = mediaSections.map((section) => {
    if (!section.startsWith('m=video')) {
      return section;
    }
    return preferH264InVideoSection(section);
  });

  const merged = [head, ...reordered].join('\r\nm=');
  return merged.endsWith('\r\n') ? merged : `${merged}\r\n`;
}

function preferH264InVideoSection(section: string): string {
  const lines = section.split(/\r\n|\n/);
  const mLineIndex = lines.findIndex((line) => line.startsWith('m=video'));
  if (mLineIndex === -1) {
    return section;
  }

  const payloadTypes: number[] = [];
  const mLine = lines[mLineIndex] ?? '';
  const parts = mLine.split(' ');
  for (let index = 3; index < parts.length; index += 1) {
    const pt = Number.parseInt(parts[index] ?? '', 10);
    if (!Number.isNaN(pt)) {
      payloadTypes.push(pt);
    }
  }

  const h264Pts: number[] = [];
  const otherPts: number[] = [];

  for (const pt of payloadTypes) {
    const rtpmap = lines.find((line) => line.startsWith(`a=rtpmap:${pt} `));
    if (rtpmap?.toLowerCase().includes('h264')) {
      h264Pts.push(pt);
    } else {
      otherPts.push(pt);
    }
  }

  if (h264Pts.length === 0) {
    return section;
  }

  const newOrder = [...h264Pts, ...otherPts];
  const mParts = mLine.split(' ');
  const rebuiltMLine = [...mParts.slice(0, 3), ...newOrder.map(String)].join(' ');
  lines[mLineIndex] = rebuiltMLine;

  return lines.join('\r\n');
}
