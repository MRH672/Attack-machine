function App() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
      <div className="text-center space-y-3">
        <p className="text-sm uppercase tracking-widest text-slate-400">Vite + React + Tailwind</p>
        <h1 className="text-4xl font-bold">Ready to build</h1>
        <p className="text-lg text-slate-300">Edit src/App.jsx and save to reload.</p>
        <div className="inline-flex gap-3">
          <a
            className="px-4 py-2 rounded-md bg-blue-600 hover:bg-blue-500 transition"
            href="https://tailwindcss.com/docs/installation"
            target="_blank"
            rel="noreferrer"
          >
            Tailwind Docs 
          </a>
          <a
            className="px-4 py-2 rounded-md bg-emerald-600 hover:bg-emerald-500 transition"
            href="https://vitejs.dev/guide/"
            target="_blank"
            rel="noreferrer"
          >
            Vite Guide
          </a>
        </div>
      </div>
    </div>
  );
}

export default App;

