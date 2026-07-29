export default function ComingSoonPage({ title, note }) {
  return (
    <div className="flex flex-col items-center justify-center text-center py-24 border border-dashed border-line rounded-lg">
      <span className="eyebrow mb-3">Module scaffolded</span>
      <h2 className="font-display text-xl font-semibold mb-2">{title}</h2>
      <p className="text-mist text-sm max-w-sm">{note}</p>
    </div>
  );
}
