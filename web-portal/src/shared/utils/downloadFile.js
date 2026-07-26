import axiosClient from '../api/axiosClient.js';

/**
 * Fetches a binary endpoint (PDF, CSV, etc.) through the authenticated
 * axios client and triggers a browser download. Needed because a plain
 * <a href="..."> to a protected API route can't carry the JWT stored in
 * localStorage - only in-app axios requests get the Authorization header.
 */
export async function downloadFile(url, filename) {
  const response = await axiosClient.get(url, { responseType: 'blob' });
  const blobUrl = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = blobUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(blobUrl);
}
