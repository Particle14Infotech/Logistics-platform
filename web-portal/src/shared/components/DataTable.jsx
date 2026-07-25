/**
 * Generic table. `columns` = [{ key, label, render? }]. `rows` = array of objects.
 */
export default function DataTable({ columns, rows, keyField = 'id' }) {
  return (
    <div className="border border-line rounded-lg overflow-hidden">
      <table className="w-full text-sm">
        <thead>
          <tr className="bg-panel2 border-b border-line">
            {columns.map((col) => (
              <th key={col.key} className="text-left px-4 py-2.5 eyebrow font-normal">
                {col.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row[keyField]} className="border-b border-line last:border-b-0 hover:bg-panel2/60 transition-colors">
              {columns.map((col) => (
                <td key={col.key} className="px-4 py-3 align-middle">
                  {col.render ? col.render(row) : row[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {rows.length === 0 && (
        <div className="px-4 py-10 text-center text-mist text-sm">Nothing here yet.</div>
      )}
    </div>
  );
}
