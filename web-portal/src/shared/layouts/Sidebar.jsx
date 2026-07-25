import { NavLink } from 'react-router-dom';

/**
 * Left dispatch-console navigation. `items` = [{ to, label, icon }]
 * `footerLabel` shows the signed-in identity above the sign-out control.
 */
export default function Sidebar({ items, footerLabel, brandSuffix }) {
  return (
    <aside className="hidden md:flex md:w-60 md:flex-col bg-panel border-r border-line shrink-0">
      <div className="h-16 flex items-center gap-2 px-5 border-b border-line">
        <div className="w-7 h-7 rounded bg-signal flex items-center justify-center">
          <span className="font-display font-bold text-ink text-sm">L</span>
        </div>
        <div className="leading-tight">
          <div className="font-display font-semibold text-[15px] tracking-tight">LOGISTICS</div>
          <div className="eyebrow -mt-0.5">{brandSuffix}</div>
        </div>
      </div>

      <nav className="flex-1 py-4 px-3 space-y-0.5 overflow-y-auto">
        {items.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                isActive
                  ? 'bg-signal/10 text-signal font-medium'
                  : 'text-mist hover:text-paper hover:bg-panel2'
              }`
            }
          >
            <span className="text-base leading-none">{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      <div className="p-3 border-t border-line">
        <div className="px-3 py-2 text-xs text-mist truncate">{footerLabel}</div>
        <button className="w-full text-left px-3 py-2 rounded-md text-sm text-mist hover:text-stop hover:bg-panel2 transition-colors">
          Sign out
        </button>
      </div>
    </aside>
  );
}
