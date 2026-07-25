const DOT_COLOR = {
  in_transit: 'bg-signal',
  idle: 'bg-mist',
  loading: 'bg-hold',
  delivered: 'bg-go',
};

/**
 * Signature element for the admin console: a horizontal strip of vehicle
 * chips styled like an airport/rail departure board - each chip is a
 * segmented "flap" showing plate, status dot, route, and ETA. This is the
 * live-fleet-map requirement (SRS 3.3.1 / 4.3) rendered as a scannable
 * ticker rather than a literal map, so it reads useful on a dashboard
 * that doesn't have room for a full Google Map embed.
 */
export default function FleetTicker({ vehicles }) {
  return (
    <div className="bg-panel border border-line rounded-lg overflow-hidden">
      <div className="flex items-center justify-between px-4 py-3 border-b border-line">
        <span className="eyebrow">Live fleet · {vehicles.length} vehicles reporting</span>
        <span className="text-xs text-mist font-mono">GPS updates every 4s</span>
      </div>
      <div className="flex overflow-x-auto no-scrollbar">
        {vehicles.map((v) => (
          <div
            key={v.plate}
            className="min-w-[190px] border-r border-line last:border-r-0 px-4 py-3 flex flex-col gap-1.5 hover:bg-panel2 transition-colors cursor-pointer"
          >
            <div className="flex items-center justify-between">
              <span className="font-mono text-sm font-medium tracking-wide">{v.plate}</span>
              <span className={`w-2 h-2 rounded-full ${DOT_COLOR[v.state] ?? 'bg-mist'}`} />
            </div>
            <div className="text-xs text-mist truncate">{v.route}</div>
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-paper/80 capitalize">{v.state.replace('_', ' ')}</span>
              <span className="text-signal">{v.eta}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
