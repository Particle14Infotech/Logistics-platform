import axiosClient from '../api/axiosClient.js';

/**
 * Fetches a binary endpoint (PDF, CSV, etc.) through the authenticated
 * axios client and triggers a browser download. Needed because a plain
 * <a href="..."> to a protected API route can't carry the JWT stored in
 * localStorage - only in-app axios requests get the Authorization header.
 */
export async function downloadFile(url, filename) {
  const response = await axiosClient.get(url, { responseType: 'blob' });
  triggerBlobDownload(new Blob([response.data]), filename);
}

/**
 * Same end result as downloadFile above, but for a document served
 * directly by the backend's static /uploads/... mount (pickup/delivery
 * documents) - an absolute URL on a different origin (api.raahmitr.com vs
 * this app's own origin), not an authenticated /api/v1/... route. A plain
 * <a download href="https://other-origin/..."> doesn't actually force a
 * download for a cross-origin URL - most browsers silently ignore the
 * `download` attribute there and just navigate/open it instead - so this
 * fetches the bytes first and downloads the resulting same-origin blob:
 * URL, which browsers always honor. No auth needed since /uploads is
 * served unauthenticated.
 */
export async function downloadFileFromUrl(url, filename) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Failed to fetch ${url}: ${response.status}`);
  triggerBlobDownload(await response.blob(), filename);
}

function triggerBlobDownload(blob, filename) {
  const blobUrl = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = blobUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(blobUrl);
}
