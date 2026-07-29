/**
 * KPI card. `trend` is a signed number (%) shown with go/stop coloring.
 */
export default function KpiCard({ label, value, unit, trend, mono = true }) {
  const trendPositive = trend >= 0;
  return (
    <div className="bg-panel border border-line rounded-lg p-4 flex flex-col gap-2">
      <span className="eyebrow">{label}</span>
      <div className="flex items-baseline gap-1.5">
        <span className={`font-display font-semibold text-2xl ${mono ? 'font-mono' : ''}`}>{value}</span>
        {unit && <span className="text-mist text-sm">{unit}</span>}
      </div>
      {trend !== undefined && (
        <div className={`flex items-center gap-1 text-xs font-mono ${trendPositive ? 'text-go' : 'text-stop'}`}>
          <span>{trendPositive ? '▲' : '▼'}</span>
          <span>{Math.abs(trend)}% vs yesterday</span>
        </div>
      )}
    </div>
  );
}
