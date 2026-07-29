/**
 * Top bar: search + live status pill + identity. Kept quiet so the
 * signature fleet ticker and KPI strip below do the visual work.
 */
export default function Topbar({ userName, userRole, dateLabel }) {
  return (
    <header className="h-16 flex items-center justify-between gap-4 px-6 border-b border-line bg-ink/80 backdrop-blur sticky top-0 z-10">
      <div className="flex items-center gap-3 flex-1 max-w-md">
        <div className="relative w-full">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-mist text-sm">⌕</span>
          <input
            type="text"
            placeholder="Search orders, drivers, waybill no."
            className="w-full bg-panel border border-line rounded-md pl-9 pr-3 py-2 text-sm placeholder:text-mist/70 focus:border-signal focus:outline-none transition-colors"
          />
        </div>
      </div>

      <div className="flex items-center gap-4">
        <span className="hidden sm:block eyebrow">{dateLabel}</span>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-go/10 text-go text-xs font-mono">
          <span className="w-1.5 h-1.5 rounded-full bg-go animate-pulse" />
          LIVE
        </div>
        <div className="flex items-center gap-2 pl-4 border-l border-line">
          <div className="w-8 h-8 rounded-full bg-panel2 border border-line flex items-center justify-center font-display text-xs font-semibold">
            {userName?.[0] ?? '?'}
          </div>
          <div className="hidden sm:block leading-tight">
            <div className="text-sm font-medium">{userName}</div>
            <div className="text-xs text-mist">{userRole}</div>
          </div>
        </div>
      </div>
    </header>
  );
}
