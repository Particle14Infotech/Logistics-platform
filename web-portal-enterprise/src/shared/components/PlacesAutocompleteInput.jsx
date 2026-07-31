import { useEffect, useRef, useState } from 'react';
import axiosClient from '../api/axiosClient.js';

// Debounced Places autocomplete, backed by the backend's /places/* proxy
// (see backend/src/controllers/places.controller.js) rather than calling
// Google directly - keeps GOOGLE_MAPS_API_KEY server-side and sidesteps
// Google's Places REST endpoints not sending CORS headers. Mirrors the
// mobile customer app's PlacesAutocompleteField (same debounce/min-length,
// same proxy) - if Maps isn't configured server-side, the backend just
// returns an empty predictions list, so this degrades to a plain text
// field with no suggestions rather than erroring.
export default function PlacesAutocompleteInput({ value, onChange, onPlaceSelected, placeholder, className, containerClassName }) {
  const [suggestions, setSuggestions] = useState([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const debounceRef = useRef(null);
  const containerRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (containerRef.current && !containerRef.current.contains(e.target)) setOpen(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleChange = (e) => {
    const next = e.target.value;
    onChange(next);
    clearTimeout(debounceRef.current);

    if (next.trim().length < 3) {
      setSuggestions([]);
      setOpen(false);
      return;
    }

    debounceRef.current = setTimeout(async () => {
      setLoading(true);
      try {
        const { data } = await axiosClient.get('/places/autocomplete', { params: { input: next } });
        setSuggestions(data.data.predictions);
        setOpen(true);
      } catch {
        setSuggestions([]);
      } finally {
        setLoading(false);
      }
    }, 400);
  };

  const handleSelect = async (prediction) => {
    onChange(prediction.description);
    setOpen(false);
    setSuggestions([]);
    try {
      const { data } = await axiosClient.get('/places/details', { params: { placeId: prediction.placeId } });
      onPlaceSelected?.(data.data);
    } catch {
      // Address text is already filled in above - a failed details lookup
      // just means no lat/lng, not a broken field.
    }
  };

  return (
    <div ref={containerRef} className={`relative ${containerClassName ?? ''}`}>
      <input
        placeholder={placeholder}
        value={value}
        onChange={handleChange}
        onFocus={() => suggestions.length > 0 && setOpen(true)}
        className={className}
        autoComplete="off"
      />
      {loading && (
        <div className="absolute right-2 top-1/2 -translate-y-1/2 text-xs text-mist">…</div>
      )}
      {open && suggestions.length > 0 && (
        <ul className="absolute z-10 mt-1 w-full max-h-56 overflow-y-auto bg-panel border border-line rounded-md shadow-lg text-sm">
          {suggestions.map((s) => (
            <li key={s.placeId}>
              <button
                type="button"
                onClick={() => handleSelect(s)}
                className="w-full text-left px-3 py-2 hover:bg-ink transition-colors"
              >
                {s.description}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
