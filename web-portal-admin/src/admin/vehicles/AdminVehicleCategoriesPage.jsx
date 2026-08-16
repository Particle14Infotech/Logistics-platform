import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

// Must match backend/src/constants/vehicleImageKeys.js - the closed set of
// illustrations bundled in both mobile apps' assets/images/vehicles/. Kept
// as a strict <select> (not free text) so every category stays visually
// consistent - see public/vehicles/ for the same PNGs used as previews here.
const IMAGE_KEYS = ['bike', 'auto', 'tata_ace', 'open', 'multi_axle_open', 'container', 'flat_bed', 'low_bed', 'semi_bed'];

// bodyType is admin-free-text on the backend (not an enum) - these are just
// autocomplete suggestions (via <datalist>) so the mobile apps' filter-chip
// labels stay consistent instead of drifting into near-duplicate spellings
// ("Open" vs "open" vs "Open Body"). Typing anything else still works.
const SUGGESTED_BODY_TYPES = ['bike', 'auto', 'open', 'container', 'trailer'];
const SUGGESTED_SUB_TYPES = ['bike', 'auto', 'tata_ace', 'open', 'multi_axle_open', 'container', 'flat_bed', 'low_bed', 'semi_bed'];

const emptyForm = {
  vehicleType: '',
  bodyType: '',
  subType: '',
  name: '',
  lengthFt: '',
  maxWeightKg: '',
  imageKey: 'open',
  baseFare: 0,
  perKmRate: 0,
  perKgRate: 0,
  advanceRequired: false,
  advanceMode: 'percentage',
  advanceValue: 30,
  sortOrder: 0,
};

// Auto-fills vehicleType (the stable slug every Order/Driver actually
// stores) from name+length so the admin doesn't have to hand-invent a slug
// for every new category - editable afterward if they want something else.
function slugify(name, lengthFt) {
  const base = name.trim().toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
  return lengthFt ? `${base}_${lengthFt}ft` : base;
}

function CategoryFormModal({ initial, onClose, onSaved }) {
  const isEdit = Boolean(initial?._id);
  const [form, setForm] = useState(() => (initial ? { ...emptyForm, ...initial } : emptyForm));
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const set = (key) => (e) => {
    const value = e?.target ? (e.target.type === 'checkbox' ? e.target.checked : e.target.value) : e;
    setForm((f) => {
      const next = { ...f, [key]: value };
      if (!slugTouched && (key === 'name' || key === 'lengthFt')) {
        next.vehicleType = slugify(key === 'name' ? value : f.name, key === 'lengthFt' ? value : f.lengthFt);
      }
      return next;
    });
  };

  const handleSave = async () => {
    setSaving(true);
    setError('');
    try {
      const payload = {
        ...form,
        lengthFt: form.lengthFt === '' ? undefined : Number(form.lengthFt),
        maxWeightKg: Number(form.maxWeightKg),
        baseFare: Number(form.baseFare),
        perKmRate: Number(form.perKmRate),
        perKgRate: Number(form.perKgRate) || 0,
        advanceValue: Number(form.advanceValue) || 0,
        sortOrder: Number(form.sortOrder) || 0,
      };
      if (isEdit) {
        await axiosClient.put(`/admin/vehicle-categories/${initial._id}`, payload);
      } else {
        await axiosClient.post('/admin/vehicle-categories', payload);
      }
      onSaved();
    } catch (err) {
      console.error('[AdminVehicleCategoriesPage] save failed', err);
      setError(err.response?.data?.message || 'Could not save this category.');
    } finally {
      setSaving(false);
    }
  };

  const input = (key, opts = {}) => (
    <input
      type={opts.type || 'text'}
      step={opts.step}
      value={form[key]}
      onChange={set(key)}
      list={opts.list}
      className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
    />
  );

  return (
    <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
      <div
        className="bg-panel border border-line rounded-xl shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto p-6 space-y-4"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between">
          <h2 className="font-display text-lg font-semibold">{isEdit ? 'Edit vehicle category' : 'Add vehicle category'}</h2>
          <button onClick={onClose} className="text-mist hover:text-signal text-sm">✕</button>
        </div>

        {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{error}</div>}

        <div className="grid md:grid-cols-2 gap-3">
          <div>
            <span className="eyebrow block mb-1">Body type</span>
            <input list="body-types" value={form.bodyType} onChange={set('bodyType')} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
            <datalist id="body-types">{SUGGESTED_BODY_TYPES.map((b) => <option key={b} value={b} />)}</datalist>
            <p className="text-xs text-mist mt-1">Top-level filter chip in both apps, e.g. "open", "container", "trailer".</p>
          </div>
          <div>
            <span className="eyebrow block mb-1">Sub type</span>
            <input list="sub-types" value={form.subType} onChange={set('subType')} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
            <datalist id="sub-types">{SUGGESTED_SUB_TYPES.map((s) => <option key={s} value={s} />)}</datalist>
          </div>
          <div>
            <span className="eyebrow block mb-1">Display name</span>
            {input('name')}
          </div>
          <div>
            <span className="eyebrow block mb-1">Length (ft, optional)</span>
            {input('lengthFt', { type: 'number' })}
          </div>
          <div>
            <span className="eyebrow block mb-1">Max weight (kg)</span>
            {input('maxWeightKg', { type: 'number' })}
          </div>
          <div>
            <span className="eyebrow block mb-1">
              vehicleType (slug) {!slugTouched && <span className="text-mist font-normal">(auto)</span>}
            </span>
            <input
              value={form.vehicleType}
              onChange={(e) => { setSlugTouched(true); setForm((f) => ({ ...f, vehicleType: e.target.value })); }}
              disabled={isEdit}
              className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors disabled:opacity-50"
            />
          </div>

          <div className="md:col-span-2">
            <span className="eyebrow block mb-1">Illustration</span>
            <div className="flex items-center gap-3 flex-wrap">
              {IMAGE_KEYS.map((key) => (
                <button
                  key={key}
                  type="button"
                  onClick={() => setForm((f) => ({ ...f, imageKey: key }))}
                  className={`flex flex-col items-center gap-1 p-2 rounded-md border ${form.imageKey === key ? 'border-signal bg-signal/10' : 'border-line'}`}
                >
                  <img src={`/vehicles/${key}.png`} alt={key} className="h-10 w-16 object-contain" />
                  <span className="text-[10px] text-mist">{key}</span>
                </button>
              ))}
            </div>
          </div>

          <div>
            <span className="eyebrow block mb-1">Base fare (₹)</span>
            {input('baseFare', { type: 'number' })}
          </div>
          <div>
            <span className="eyebrow block mb-1">Per km (₹)</span>
            {input('perKmRate', { type: 'number' })}
          </div>
          <div>
            <span className="eyebrow block mb-1">Per kg (₹)</span>
            {input('perKgRate', { type: 'number', step: 0.1 })}
          </div>
          <div>
            <span className="eyebrow block mb-1">Sort order</span>
            {input('sortOrder', { type: 'number' })}
          </div>

          <div className="md:col-span-2 border-t border-line pt-3">
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={form.advanceRequired} onChange={set('advanceRequired')} />
              Requires advance payment
            </label>
          </div>
          {form.advanceRequired && (
            <>
              <div>
                <span className="eyebrow block mb-1">Advance mode</span>
                <select value={form.advanceMode} onChange={set('advanceMode')} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors">
                  <option value="percentage">Percentage</option>
                  <option value="fixed">Fixed amount</option>
                </select>
              </div>
              <div>
                <span className="eyebrow block mb-1">{form.advanceMode === 'fixed' ? 'Amount (₹)' : 'Percentage (%)'}</span>
                {input('advanceValue', { type: 'number', step: form.advanceMode === 'fixed' ? 1 : 0.5 })}
              </div>
            </>
          )}
        </div>

        <div className="flex justify-end gap-2 pt-2">
          <button onClick={onClose} className="border border-line text-sm rounded-md px-4 py-2 hover:border-signal transition-colors">Cancel</button>
          <button
            onClick={handleSave}
            disabled={saving || !form.bodyType || !form.subType || !form.name || !form.vehicleType || !form.maxWeightKg}
            className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-40 transition-all"
          >
            {saving ? 'Saving…' : isEdit ? 'Save changes' : 'Create category'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function AdminVehicleCategoriesPage() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [editing, setEditing] = useState(null); // null=closed, {}=create, {...}=edit
  const [actionError, setActionError] = useState('');

  const fetchCategories = async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/vehicle-categories');
      setCategories(data.data.categories);
    } catch (err) {
      console.error('[AdminVehicleCategoriesPage] failed to load', err);
      setError(err.response?.data?.message || 'Could not load vehicle categories.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchCategories(); }, []);

  const toggleActive = async (category) => {
    setActionError('');
    try {
      await axiosClient.put(`/admin/vehicle-categories/${category._id}`, { isActive: !category.isActive });
      await fetchCategories();
    } catch (err) {
      console.error('[AdminVehicleCategoriesPage] toggle failed', err);
      setActionError(err.response?.data?.message || 'Could not update this category.');
    }
  };

  const handleDelete = async (category) => {
    if (!window.confirm(`Delete "${category.name}"? Only possible if no driver/order has ever used it - deactivate instead if you're not sure.`)) return;
    setActionError('');
    try {
      await axiosClient.delete(`/admin/vehicle-categories/${category._id}`);
      await fetchCategories();
    } catch (err) {
      console.error('[AdminVehicleCategoriesPage] delete failed', err);
      setActionError(err.response?.data?.message || 'Could not delete this category.');
    }
  };

  const columns = [
    {
      key: 'image', label: '', render: (c) => (
        <img src={`/vehicles/${IMAGE_KEYS.includes(c.imageKey) ? c.imageKey : 'open'}.png`} alt={c.name} className="h-8 w-14 object-contain" />
      ),
    },
    {
      key: 'name', label: 'Category', render: (c) => (
        <div>
          <div className="font-medium">{c.name}{c.lengthFt ? ` • ${c.lengthFt}ft` : ''}</div>
          <div className="text-xs text-mist capitalize">{c.bodyType} / {c.subType}</div>
        </div>
      ),
    },
    { key: 'vehicleType', label: 'Slug', render: (c) => <span className="font-mono text-xs">{c.vehicleType}</span> },
    { key: 'maxWeightKg', label: 'Max weight', render: (c) => `${c.maxWeightKg} kg` },
    { key: 'baseFare', label: 'Base fare', render: (c) => `₹${c.baseFare}` },
    { key: 'perKmRate', label: 'Per km', render: (c) => `₹${c.perKmRate}` },
    {
      key: 'isActive', label: 'Status', render: (c) => (
        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${c.isActive ? 'bg-go/10 text-go' : 'bg-mist/10 text-mist'}`}>
          {c.isActive ? 'Active' : 'Inactive'}
        </span>
      ),
    },
    {
      key: 'actions', label: '', render: (c) => (
        <div className="flex items-center gap-3 text-xs">
          <button onClick={() => setEditing(c)} className="text-signal hover:underline">Edit</button>
          <button onClick={() => toggleActive(c)} className="text-mist hover:text-signal">{c.isActive ? 'Deactivate' : 'Activate'}</button>
          <button onClick={() => handleDelete(c)} className="text-stop hover:underline">Delete</button>
        </div>
      ),
    },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div className="flex items-start justify-between flex-wrap gap-3">
        <div>
          <span className="eyebrow">Revenue</span>
          <h1 className="font-display text-2xl font-semibold mt-1">Vehicle categories</h1>
          <p className="text-mist text-sm mt-1">
            Every vehicle type customers can book and drivers can register as, with its own price, weight limit, and illustration.
            Both mobile apps fetch this catalog live - a change here shows up without an app update.
          </p>
        </div>
        <button
          onClick={() => setEditing({})}
          className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all whitespace-nowrap"
        >
          + Add category
        </button>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}
      {actionError && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{actionError}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading categories…</div>
      ) : (
        <DataTable columns={columns} rows={categories} keyField="_id" />
      )}

      {editing !== null && (
        <CategoryFormModal
          initial={editing._id ? editing : null}
          onClose={() => setEditing(null)}
          onSaved={() => { setEditing(null); fetchCategories(); }}
        />
      )}
    </ConsoleShell>
  );
}
