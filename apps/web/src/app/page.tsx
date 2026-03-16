export default function Home() {
  return (
    <div className="min-h-screen bg-white text-black font-sans flex flex-col items-center justify-center p-8">
      <header className="max-w-md w-full flex justify-between items-center mb-16">
        <h1 className="text-sm font-bold tracking-widest uppercase text-[#A07840]">HON</h1>
        <nav className="flex gap-4 text-xs text-[#aaaaaa]">
          <a href="#" className="hover:text-black">Features</a>
          <a href="#" className="hover:text-black">Pricing</a>
          <a href="#" className="hover:text-black">Login</a>
        </nav>
      </header>

      <main className="max-w-md w-full text-center">
        <h2 className="text-4xl font-medium mb-4 tracking-tight">Habits Over Numbers</h2>
        <p className="text-[#aaaaaa] mb-12 text-sm leading-relaxed">
          The ultra-minimalist focus timer for macOS. 
          Capture your sessions, organize by category, and protect your wellbeing.
        </p>

        <div className="flex flex-col gap-4">
          <button className="w-full bg-[#111111] text-white py-3 rounded-lg text-sm hover:bg-[#222222] transition-colors">
            Download for macOS
          </button>
          <button className="w-full border border-[#d0d0d0] text-black py-3 rounded-lg text-sm hover:bg-[#f5f5f5] transition-colors">
            Continue with Google
          </button>
        </div>
      </main>

      <footer className="mt-24 text-[10px] text-[#aaaaaa] uppercase tracking-widest">
        &copy; 2026 HON · Offline First · Premium Simplicity
      </footer>
    </div>
  )
}
