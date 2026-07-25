const STATUS_STYLES = {
  pending: 'bg-hold/10 text-hold',
  accepted: 'bg-signal/10 text-signal',
  picked_up: 'bg-signal/10 text-signal',
  in_transit: 'bg-signal/10 text-signal',
  delivered: 'bg-go/10 text-go',
  cancelled: 'bg-stop/10 text-stop',
  online: 'bg-go/10 text-go',
  offline: 'bg-mist/10 text-mist',
  paid: 'bg-go/10 text-go',
  overdue: 'bg-stop/10 text-stop',
  draft: 'bg-mist/10 text-mist',
  sent: 'bg-hold/10 text-hold',
};

const STATUS_LABELS = {
  pending: 'Pending',
  accepted: 'Accepted',
  picked_up: 'Picked up',
  in_transit: 'In transit',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
  online: 'Online',
  offline: 'Offline',
  paid: 'Paid',
  overdue: 'Overdue',
  draft: 'Draft',
  sent: 'Sent',
};

export default function StatusBadge({ status }) {
  const style = STATUS_STYLES[status] ?? 'bg-mist/10 text-mist';
  const label = STATUS_LABELS[status] ?? status;
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium ${style}`}>
      {label}
    </span>
  );
}
