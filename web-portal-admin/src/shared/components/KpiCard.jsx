/**
 * KPI card. `trend` is a signed number (%) shown with go/stop coloring.
 * `mono` defaults to false - the headline number reads in the display font,
 * not monospace. Monospace on every big stat is a big part of what made
 * this read as a trading terminal rather than a transport ops dashboard;
 * reserve it for genuinely tabular data (table cells, plate numbers).
 * `onClick`, when given, makes the whole card an actual button that
 * navigates to the relevant filtered list instead of being pure display.
 */
export default function KpiCard({ label, value, unit, trend, mono = false, onClick }) {
  const trendPositive = trend >= 0;
  const Wrapper = onClick ? 'button' : 'div';
  return (
    <Wrapper
      onClick={onClick}
      className={`bg-panel border border-line rounded-xl shadow-sm p-4 flex flex-col gap-2 text-left w-full ${
        onClick ? 'cursor-pointer hover:border-signal hover:shadow-md transition-all' : ''
      }`}
    >
      <span className="eyebrow">{label}</span>
      <div className="flex items-baseline gap-1.5">
        <span className={`font-display font-semibold text-2xl ${mono ? 'font-mono' : ''}`}>{value}</span>
        {unit && <span className="text-mist text-sm">{unit}</span>}
      </div>
      {trend !== undefined && (
        <div className={`flex items-center gap-1 text-xs font-body font-medium ${trendPositive ? 'text-go' : 'text-stop'}`}>
          <span>{trendPositive ? '▲' : '▼'}</span>
          <span>{Math.abs(trend)}% vs yesterday</span>
        </div>
      )}
    </Wrapper>
  );
}
