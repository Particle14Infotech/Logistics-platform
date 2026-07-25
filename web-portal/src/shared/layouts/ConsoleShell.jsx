import Sidebar from './Sidebar.jsx';
import Topbar from './Topbar.jsx';

export default function ConsoleShell({ navItems, brandSuffix, footerLabel, userName, userRole, dateLabel, children }) {
  return (
    <div className="min-h-screen flex bg-ink text-paper font-body">
      <Sidebar items={navItems} brandSuffix={brandSuffix} footerLabel={footerLabel} />
      <div className="flex-1 flex flex-col min-w-0">
        <Topbar userName={userName} userRole={userRole} dateLabel={dateLabel} />
        <main className="flex-1 p-6 space-y-8 max-w-[1400px] w-full mx-auto">{children}</main>
      </div>
    </div>
  );
}
