import { useState } from "react";

// ─── ICONS ───────────────────────────────────────────────────────────────────
const Icon = ({ d, size = 18, stroke = "currentColor", fill = "none", strokeWidth = 1.8 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round">
    <path d={d} />
  </svg>
);

const icons = {
  recipes:    "M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2M9 5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2M9 5a2 2 0 0 0 2-2h2a2 2 0 0 0 2 2",
  calendar:   "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z",
  cart:       "M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-8 2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z",
  pantry:     "M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z",
  stats:      "M18 20V10M12 20V4M6 20v-6",
  search:     "M21 21l-6-6m2-5a7 7 0 1 1-14 0 7 7 0 0 1 14 0z",
  filter:     "M3 4h18M7 12h10M10 20h4",
  plus:       "M12 5v14M5 12h14",
  check:      "M20 6L9 17l-5-5",
  chevLeft:   "M15 18l-6-6 6-6",
  chevRight:  "M9 18l6-6-6-6",
  trash:      "M3 6h18M8 6V4h8v2M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6",
  edit:       "M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z",
  back:       "M19 12H5M12 5l-7 7 7 7",
  clock:      "M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zm0-6v-4l3-3",
  dots:       "M5 12h.01M12 12h.01M19 12h.01",
  pie:        "M21.21 15.89A10 10 0 1 1 8 2.83M22 12A10 10 0 0 0 12 2v10z",
  bookmark:   "M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z",
  image:      "M4 16l4.586-4.586a2 2 0 0 1 2.828 0L16 16m-2-2l1.586-1.586a2 2 0 0 1 2.828 0L20 14M6 20h12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z",
  warn:       "M12 9v4M12 17h.01M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z",
  x:          "M18 6L6 18M6 6l12 12",
};

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
const NAV_ITEMS = [
  { id: "recipes",      label: "Ricette",     icon: icons.recipes },
  { id: "piano",        label: "Piano",       icon: icons.calendar },
  { id: "spesa",        label: "Spesa",       icon: icons.cart },
  { id: "dispensa",     label: "Dispensa",    icon: icons.pantry },
  { id: "statistiche",  label: "Statistiche", icon: icons.stats },
];

function BottomNav({ active, setActive }) {
  return (
    <nav style={{ display:"flex", borderTop:"1px solid #e5e7eb", background:"#fff", padding:"6px 0 4px", flexShrink:0 }}>
      {NAV_ITEMS.map(({ id, label, icon }) => (
        <button key={id} onClick={() => setActive(id)} style={{
          flex:1, display:"flex", flexDirection:"column", alignItems:"center", gap:2,
          border:"none", background:"none", cursor:"pointer",
          color: active===id ? "#111" : "#9ca3af",
          fontSize:10, fontFamily:"inherit", fontWeight: active===id ? 700 : 400, padding:"4px 0",
        }}>
          <Icon d={icon} size={20} strokeWidth={active===id ? 2.2 : 1.6} />
          {label}
        </button>
      ))}
    </nav>
  );
}

// ─── SHARED UI COMPONENTS ─────────────────────────────────────────────────────
function SearchBar({ placeholder }) {
  return (
    <div style={{ position:"relative", marginBottom:10 }}>
      <span style={{ position:"absolute", left:10, top:"50%", transform:"translateY(-50%)", color:"#9ca3af" }}>
        <Icon d={icons.search} size={15} />
      </span>
      <input placeholder={placeholder} readOnly style={{
        width:"100%", boxSizing:"border-box", padding:"8px 10px 8px 32px",
        border:"1px solid #e5e7eb", borderRadius:8, fontSize:13,
        color:"#374151", background:"#f9fafb", outline:"none", fontFamily:"inherit",
      }} />
    </div>
  );
}

function Chip({ label, active, onClick }) {
  return (
    <span onClick={onClick} style={{
      padding:"4px 10px", borderRadius:20, fontSize:12, cursor:"pointer", whiteSpace:"nowrap",
      background: active ? "#111" : "#f3f4f6",
      color: active ? "#fff" : "#374151",
      border: active ? "1px solid #111" : "1px solid #e5e7eb",
    }}>{label}</span>
  );
}

function Card({ children, style={}, onClick }) {
  return (
    <div onClick={onClick} style={{
      border:"1px solid #e5e7eb", borderRadius:12, padding:"12px",
      marginBottom:10, background:"#fff", cursor: onClick ? "pointer" : "default", ...style,
    }}>{children}</div>
  );
}

function SaveBtn({ label="Salva", onClick }) {
  return (
    <button onClick={onClick} style={{
      width:"100%", padding:"13px", background:"#111", color:"#fff",
      border:"none", borderRadius:10, fontSize:15, fontWeight:600,
      cursor:"pointer", fontFamily:"inherit", marginTop:4,
    }}>{label}</button>
  );
}

function DangerBtn({ label, onClick }) {
  return (
    <button onClick={onClick} style={{
      width:"100%", textAlign:"center", marginTop:12, background:"none",
      border:"none", color:"#ef4444", fontSize:13, cursor:"pointer", fontFamily:"inherit",
    }}>{label}</button>
  );
}

function FormField({ label, placeholder, value, children }) {
  return (
    <div style={{ marginBottom:14 }}>
      <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>{label}</label>
      {children || (
        <input placeholder={placeholder} defaultValue={value} style={{
          width:"100%", boxSizing:"border-box", padding:"9px 12px",
          border:"1px solid #e5e7eb", borderRadius:8, fontSize:13,
          fontFamily:"inherit", outline:"none", background:"#fff",
        }} />
      )}
    </div>
  );
}

function SelectField({ label, value }) {
  return (
    <div style={{ marginBottom:14 }}>
      {label && <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>{label}</label>}
      <div style={{
        display:"flex", alignItems:"center", justifyContent:"space-between",
        padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, color:"#374151",
      }}>
        <span>{value}</span>
        <span style={{ color:"#9ca3af" }}>▾</span>
      </div>
    </div>
  );
}

function SubHeader({ title, onBack, rightAction }) {
  return (
    <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:16, flexShrink:0 }}>
      <button onClick={onBack} style={{ background:"none", border:"none", cursor:"pointer", padding:0, display:"flex" }}>
        <Icon d={icons.back} size={20} />
      </button>
      <span style={{ fontWeight:700, fontSize:16 }}>{title}</span>
      {rightAction || <span style={{ width:20 }} />}
    </div>
  );
}

function CheckIcon() {
  return (
    <button style={{ background:"none", border:"none", cursor:"pointer", padding:0 }}>
      <Icon d={icons.check} size={20} />
    </button>
  );
}

function FabButton({ onClick }) {
  return (
    <button onClick={onClick} style={{
      position:"absolute", bottom:16, right:18, width:46, height:46,
      borderRadius:"50%", background:"#111", color:"#fff", border:"none",
      fontSize:24, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center",
      boxShadow:"0 4px 12px rgba(0,0,0,0.25)", zIndex:10,
    }}>
      <Icon d={icons.plus} size={22} stroke="#fff" />
    </button>
  );
}

// ─── DATA ─────────────────────────────────────────────────────────────────────
const INIT_RECIPES = [
  { id:1, name:"Spaghetti alla Carbonara", cat:"Pasta",   time:"20 min", diff:"Media",  portions:2,
    ingredients:["Spaghetti 200 g","Uova 2","Guanciale 100 g","Pecorino Romano 50 g","Pepe nero q.b."],
    steps:["Cuoci gli spaghetti in acqua salata.","Rosola il guanciale in padella senza olio.","Sbatti le uova con il pecorino e pepe.","Scola la pasta e manteca fuori dal fuoco con il condimento."],
    note:"" },
  { id:2, name:"Insalata Caesar",           cat:"Insalata", time:"15 min", diff:"Facile", portions:2,
    ingredients:["Lattuga romana 1","Parmigiano 30 g","Crostini 50 g","Salsa Caesar 3 cucchiai"],
    steps:["Lava e asciuga la lattuga.","Prepara la salsa caesar.","Aggiungi i crostini e il parmigiano."],
    note:"" },
  { id:3, name:"Burger di Manzo",           cat:"Secondi",  time:"30 min", diff:"Media",  portions:2,
    ingredients:["Carne macinata 300 g","Panini da burger 2","Pomodoro 1","Lattuga 2 foglie","Formaggio 2 fette"],
    steps:["Forma i burger e condisci con sale e pepe.","Cuoci 4 min per lato su griglia calda.","Assembla con gli ingredienti."],
    note:"" },
  { id:4, name:"Zuppa di Lenticchie",       cat:"Zuppe",    time:"40 min", diff:"Facile", portions:4,
    ingredients:["Lenticchie 300 g","Carota 1","Sedano 1","Cipolla 1","Pomodori pelati 200 g","Brodo 1 L"],
    steps:["Soffriggi le verdure in olio.","Aggiungi le lenticchie e i pomodori.","Versa il brodo e cuoci 30 min."],
    note:"" },
];

const INIT_PANTRY = [
  { id:1, name:"Latte",           qty:"1",   unit:"L",   cat:"Latticini",  exp:"12/05/2024", status:"scadenza" },
  { id:2, name:"Pasta",           qty:"100", unit:"g",   cat:"Cereali",    exp:"",           status:"esaurimento" },
  { id:3, name:"Riso",            qty:"1",   unit:"kg",  cat:"Cereali",    exp:"30/06/2024", status:"ok" },
  { id:4, name:"Olio Extra Vergine", qty:"500", unit:"ml", cat:"Condimenti", exp:"20/12/2024", status:"ok" },
  { id:5, name:"Farina 00",       qty:"1",   unit:"kg",  cat:"Cereali",    exp:"10/07/2024", status:"ok" },
];

const INIT_SHOPPING = [
  { id:1, name:"Latte",              qty:"1",   unit:"L",         cat:"Latticini", checked:false },
  { id:2, name:"Spaghetti",          qty:"500", unit:"g",         cat:"Cereali",   checked:true  },
  { id:3, name:"Uova",               qty:"6",   unit:"pz",        cat:"Uova",      checked:false },
  { id:4, name:"Pomodori",           qty:"500", unit:"g",         cat:"Verdure",   checked:false },
  { id:5, name:"Parmigiano Reggiano",qty:"100", unit:"g",         cat:"Latticini", checked:false },
  { id:6, name:"Basilico",           qty:"1",   unit:"mazzetto",  cat:"Verdure",   checked:false },
];

const INIT_PLAN = {
  "Lunedì":    { colazione:"",                      pranzo:"Spaghetti alla Carbonara", cena:"Insalata Caesar" },
  "Martedì":   { colazione:"Toast e Caffè",          pranzo:"Burger di Manzo",          cena:"Zuppa di Lenticchie" },
  "Mercoledì": { colazione:"Yogurt e Frutta",        pranzo:"Pasta al Pesto",           cena:"" },
  "Giovedì":   { colazione:"",                      pranzo:"",                          cena:"" },
  "Venerdì":   { colazione:"",                      pranzo:"",                          cena:"" },
  "Sabato":    { colazione:"",                      pranzo:"",                          cena:"" },
  "Domenica":  { colazione:"",                      pranzo:"",                          cena:"" },
};

const STATUS_COLORS = {
  scadenza:   { bg:"#fef3c7", text:"#92400e", label:"In scadenza" },
  esaurimento:{ bg:"#fee2e2", text:"#991b1b", label:"In esaurimento" },
  ok:         { bg:"#f0fdf4", text:"#166534", label:"OK" },
};

// ─── SCREEN 1: RICETTE ────────────────────────────────────────────────────────
function AddEditRecipeForm({ recipe, onBack, onSave, onDelete }) {
  const isEdit = !!recipe;
  const [name,  setName]  = useState(recipe?.name  || "");
  const [cat,   setCat]   = useState(recipe?.cat   || "Pasta");
  const [time,  setTime]  = useState(recipe?.time  || "");
  const [diff,  setDiff]  = useState(recipe?.diff  || "Facile");
  const [ing,   setIng]   = useState(recipe?.ingredients?.join("\n") || "");
  const [steps, setSteps] = useState(recipe?.steps?.join("\n")       || "");
  const [note,  setNote]  = useState(recipe?.note  || "");

  const textareaStyle = {
    width:"100%", boxSizing:"border-box", padding:"9px 12px",
    border:"1px solid #e5e7eb", borderRadius:8, fontSize:13,
    fontFamily:"inherit", outline:"none", resize:"vertical", minHeight:80,
  };

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader
        title={isEdit ? "Modifica ricetta" : "Nuova ricetta"}
        onBack={onBack}
        rightAction={<CheckIcon />}
      />
      <div style={{ flex:1, overflowY:"auto" }}>
        {/* Image placeholder */}
        <div style={{ background:"#f3f4f6", borderRadius:10, height:110, marginBottom:14,
          display:"flex", alignItems:"center", justifyContent:"center", flexDirection:"column", gap:6, color:"#9ca3af" }}>
          <Icon d={icons.image} size={28} />
          <span style={{ fontSize:12 }}>Aggiungi foto</span>
        </div>

        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Nome ricetta</label>
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="Es. Pasta al pesto"
            style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
        </div>

        <div style={{ display:"flex", gap:8 }}>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Categoria</label>
            <select value={cat} onChange={e=>setCat(e.target.value)} style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
              {["Pasta","Insalata","Secondi","Zuppe","Dolci","Antipasti"].map(c=><option key={c}>{c}</option>)}
            </select>
          </div>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Difficoltà</label>
            <select value={diff} onChange={e=>setDiff(e.target.value)} style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
              {["Facile","Media","Difficile"].map(d=><option key={d}>{d}</option>)}
            </select>
          </div>
        </div>

        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Tempo di preparazione</label>
          <input value={time} onChange={e=>setTime(e.target.value)} placeholder="Es. 20 min"
            style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
        </div>

        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Ingredienti <span style={{fontWeight:400,color:"#9ca3af"}}>(uno per riga)</span></label>
          <textarea value={ing} onChange={e=>setIng(e.target.value)} placeholder="Es. Spaghetti 200 g" style={textareaStyle} />
        </div>

        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Procedimento <span style={{fontWeight:400,color:"#9ca3af"}}>(un passo per riga)</span></label>
          <textarea value={steps} onChange={e=>setSteps(e.target.value)} placeholder="Es. Cuoci la pasta..." style={textareaStyle} />
        </div>

        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Note</label>
          <textarea value={note} onChange={e=>setNote(e.target.value)} placeholder="Aggiungi una nota..." style={{ ...textareaStyle, minHeight:56 }} />
        </div>

        <SaveBtn label="Salva ricetta" onClick={() => onSave({ name, cat, time, diff, ingredients: ing.split("\n").filter(Boolean), steps: steps.split("\n").filter(Boolean), note })} />
        {isEdit && <DangerBtn label="Elimina ricetta" onClick={() => onDelete(recipe.id)} />}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

function RecipeDetail({ recipe, onBack, onEdit }) {
  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader title={recipe.name} onBack={onBack}
        rightAction={
          <div style={{ display:"flex", gap:10 }}>
            <button onClick={onEdit} style={{ background:"none", border:"none", cursor:"pointer" }}><Icon d={icons.edit} size={18} /></button>
          </div>
        }
      />
      <div style={{ flex:1, overflowY:"auto" }}>
        <div style={{ background:"#f3f4f6", borderRadius:10, height:140, marginBottom:12,
          display:"flex", alignItems:"center", justifyContent:"center", color:"#9ca3af", flexDirection:"column", gap:4 }}>
          <Icon d={icons.image} size={28} />
          <span style={{ fontSize:11 }}>Immagine ricetta</span>
        </div>
        <div style={{ display:"flex", gap:16, marginBottom:14, fontSize:12, color:"#6b7280" }}>
          <span>⏱ {recipe.time}</span>
          <span>◎ {recipe.diff}</span>
          <span>👥 {recipe.portions} Porzioni</span>
        </div>
        <div style={{ marginBottom:14 }}>
          <strong style={{ fontSize:14 }}>Ingredienti</strong>
          <ul style={{ paddingLeft:18, marginTop:6, fontSize:13, color:"#374151", lineHeight:1.8 }}>
            {recipe.ingredients.map((i,idx) => <li key={idx}>{i}</li>)}
          </ul>
        </div>
        <div style={{ marginBottom:14 }}>
          <strong style={{ fontSize:14 }}>Procedimento</strong>
          <ol style={{ paddingLeft:18, marginTop:6, fontSize:13, color:"#374151", lineHeight:1.9 }}>
            {recipe.steps.map((s,idx) => <li key={idx}>{s}</li>)}
          </ol>
        </div>
        <div style={{ marginBottom:16 }}>
          <strong style={{ fontSize:14 }}>Note</strong>
          <div style={{ fontSize:13, color: recipe.note ? "#374151" : "#9ca3af", marginTop:6,
            padding:"8px 10px", border:"1px solid #e5e7eb", borderRadius:8, minHeight:40 }}>
            {recipe.note || "Aggiungi una nota..."}
          </div>
        </div>
      </div>
    </div>
  );
}

function ScreenRicette() {
  const [recipes, setRecipes] = useState(INIT_RECIPES);
  const [view, setView]       = useState("list"); // list | detail | add | edit
  const [selected, setSelected] = useState(null);
  const [filterCat, setFilterCat] = useState("Tutte");

  const cats = ["Tutte", ...Array.from(new Set(recipes.map(r=>r.cat)))];
  const filtered = filterCat==="Tutte" ? recipes : recipes.filter(r=>r.cat===filterCat);

  const handleSave = (data) => {
    if (view==="edit") {
      setRecipes(prev => prev.map(r => r.id===selected.id ? { ...r, ...data } : r));
    } else {
      const newR = { id: Date.now(), portions:2, ...data };
      setRecipes(prev => [...prev, newR]);
    }
    setView("list");
  };

  const handleDelete = (id) => {
    setRecipes(prev => prev.filter(r => r.id!==id));
    setView("list");
  };

  if (view==="add")  return <AddEditRecipeForm onBack={()=>setView("list")} onSave={handleSave} onDelete={handleDelete} />;
  if (view==="edit") return <AddEditRecipeForm recipe={selected} onBack={()=>setView("detail")} onSave={handleSave} onDelete={handleDelete} />;
  if (view==="detail") return <RecipeDetail recipe={selected} onBack={()=>setView("list")} onEdit={()=>setView("edit")} />;

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%", position:"relative" }}>
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:14 }}>
        <h1 style={{ fontSize:20, fontWeight:700, margin:0 }}>Ricette</h1>
        <Icon d={icons.filter} size={18} />
      </div>
      <SearchBar placeholder="Cerca ricetta..." />
      <div style={{ display:"flex", gap:6, marginBottom:12, overflowX:"auto", paddingBottom:2 }}>
        {cats.map(c => <Chip key={c} label={c} active={filterCat===c} onClick={()=>setFilterCat(c)} />)}
      </div>
      <div style={{ flex:1, overflowY:"auto" }}>
        {filtered.map(r => (
          <Card key={r.id} style={{ display:"flex", gap:10, padding:"10px" }}
            onClick={() => { setSelected(r); setView("detail"); }}>
            <div style={{ width:52, height:52, background:"#f3f4f6", borderRadius:8, flexShrink:0,
              display:"flex", alignItems:"center", justifyContent:"center", color:"#d1d5db" }}>
              <Icon d={icons.image} size={20} />
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontWeight:600, fontSize:14, marginBottom:2 }}>{r.name}</div>
              <div style={{ fontSize:12, color:"#6b7280", marginBottom:4 }}>{r.cat}</div>
              <div style={{ display:"flex", gap:10, fontSize:11, color:"#6b7280" }}>
                <span>⏱ {r.time}</span>
                <span>◎ {r.diff}</span>
              </div>
            </div>
          </Card>
        ))}
        <div style={{ height:64 }} />
      </div>
      <FabButton onClick={() => setView("add")} />
    </div>
  );
}

// ─── SCREEN 2: PIANO PASTI ────────────────────────────────────────────────────
const WEEK_DAYS = ["Lunedì","Martedì","Mercoledì","Giovedì","Venerdì","Sabato","Domenica"];
const MEALS     = ["colazione","pranzo","cena"];

function AddMealForm({ existing, day, meal, onBack, onSave, onDelete, recipeNames }) {
  const [selDay,  setSelDay]  = useState(day  || WEEK_DAYS[0]);
  const [selMeal, setSelMeal] = useState(meal || "pranzo");
  const [selRec,  setSelRec]  = useState(existing || "");

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader title="Aggiungi / Modifica pasto" onBack={onBack} rightAction={<CheckIcon />} />
      <div style={{ flex:1, overflowY:"auto" }}>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Giorno</label>
          <select value={selDay} onChange={e=>setSelDay(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            {WEEK_DAYS.map(d=><option key={d}>{d}</option>)}
          </select>
        </div>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Tipologia pasto</label>
          <select value={selMeal} onChange={e=>setSelMeal(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            {MEALS.map(m=><option key={m} style={{ textTransform:"capitalize" }}>{m}</option>)}
          </select>
        </div>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Ricetta</label>
          <select value={selRec} onChange={e=>setSelRec(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            <option value="">— Nessuna —</option>
            {recipeNames.map(n=><option key={n}>{n}</option>)}
          </select>
        </div>
        <SaveBtn onClick={() => onSave(selDay, selMeal, selRec)} />
        {existing && <DangerBtn label="Elimina pasto" onClick={() => onDelete(selDay, selMeal)} />}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

function ScreenPiano({ recipeNames }) {
  const [plan, setPlan]   = useState(INIT_PLAN);
  const [addMeal, setAdd] = useState(false);
  const [editCtx, setEditCtx] = useState(null); // { day, meal, value }

  const openAdd  = () => { setEditCtx(null); setAdd(true); };
  const openEdit = (day, meal, value) => { setEditCtx({ day, meal, value }); setAdd(true); };

  const handleSave = (day, meal, value) => {
    setPlan(prev => ({ ...prev, [day]: { ...prev[day], [meal]: value } }));
    setAdd(false);
  };
  const handleDelete = (day, meal) => {
    setPlan(prev => ({ ...prev, [day]: { ...prev[day], [meal]: "" } }));
    setAdd(false);
  };

  if (addMeal) return (
    <AddMealForm
      existing={editCtx?.value}
      day={editCtx?.day}
      meal={editCtx?.meal}
      onBack={() => setAdd(false)}
      onSave={handleSave}
      onDelete={handleDelete}
      recipeNames={recipeNames}
    />
  );

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%", position:"relative" }}>
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:14 }}>
        <h1 style={{ fontSize:20, fontWeight:700, margin:0 }}>Piano pasti</h1>
        <Icon d={icons.calendar} size={18} />
      </div>
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:12,
        background:"#f9fafb", borderRadius:8, padding:"7px 12px" }}>
        <Icon d={icons.chevLeft} size={16} />
        <span style={{ fontSize:14, fontWeight:600 }}>20 – 26 Maggio</span>
        <Icon d={icons.chevRight} size={16} />
      </div>
      <div style={{ flex:1, overflowY:"auto" }}>
        {WEEK_DAYS.map(day => (
          <Card key={day}>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:8 }}>
              <strong style={{ fontSize:14 }}>{day}</strong>
              <button onClick={openAdd} style={{ background:"none", border:"none", cursor:"pointer" }}>
                <Icon d={icons.dots} size={16} />
              </button>
            </div>
            {MEALS.map(m => (
              <div key={m} onClick={() => openEdit(day, m, plan[day]?.[m]||"")}
                style={{ display:"flex", fontSize:12, marginBottom:4, cursor:"pointer", padding:"2px 0" }}>
                <span style={{ width:76, color:"#6b7280", textTransform:"capitalize", flexShrink:0 }}>{m}</span>
                <span style={{ color: plan[day]?.[m] ? "#111" : "#d1d5db" }}>{plan[day]?.[m] || "–"}</span>
              </div>
            ))}
          </Card>
        ))}
        <div style={{ height:64 }} />
      </div>
      <FabButton onClick={openAdd} />
    </div>
  );
}

// ─── SCREEN 3: SPESA ─────────────────────────────────────────────────────────
function AddShoppingItemForm({ item, onBack, onSave, onDelete }) {
  const isEdit = !!item;
  const [name, setName] = useState(item?.name || "");
  const [qty,  setQty]  = useState(item?.qty  || "");
  const [unit, setUnit] = useState(item?.unit || "g");
  const [cat,  setCat]  = useState(item?.cat  || "Altro");

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader title={isEdit ? "Modifica articolo" : "Aggiungi articolo"} onBack={onBack} rightAction={<CheckIcon />} />
      <div style={{ flex:1, overflowY:"auto" }}>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Nome prodotto</label>
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="Es. Latte"
            style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
        </div>
        <div style={{ display:"flex", gap:8 }}>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Quantità</label>
            <input value={qty} onChange={e=>setQty(e.target.value)} placeholder="Es. 1"
              style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
          </div>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Unità di misura</label>
            <select value={unit} onChange={e=>setUnit(e.target.value)}
              style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
              {["g","kg","ml","L","pz","mazzetto","confezione"].map(u=><option key={u}>{u}</option>)}
            </select>
          </div>
        </div>
        <div style={{ marginBottom:14, marginTop:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Categoria</label>
          <select value={cat} onChange={e=>setCat(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            {["Latticini","Cereali","Verdure","Frutta","Carne","Pesce","Uova","Condimenti","Altro"].map(c=><option key={c}>{c}</option>)}
          </select>
        </div>
        <SaveBtn onClick={() => onSave({ name, qty, unit, cat })} />
        {isEdit && <DangerBtn label="Rimuovi dalla lista" onClick={() => onDelete(item.id)} />}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

function ScreenSpesa() {
  const [items,   setItems]   = useState(INIT_SHOPPING);
  const [view,    setView]    = useState("list");
  const [editItem,setEditItem] = useState(null);

  const toggle = (id) => setItems(prev => prev.map(i => i.id===id ? {...i, checked:!i.checked} : i));

  const handleSave = (data) => {
    if (editItem) {
      setItems(prev => prev.map(i => i.id===editItem.id ? {...i, ...data} : i));
    } else {
      setItems(prev => [...prev, { id:Date.now(), checked:false, ...data }]);
    }
    setView("list");
  };

  const handleDelete = (id) => {
    setItems(prev => prev.filter(i => i.id!==id));
    setView("list");
  };

  if (view==="add" || view==="edit") return (
    <AddShoppingItemForm
      item={view==="edit" ? editItem : null}
      onBack={() => setView("list")}
      onSave={handleSave}
      onDelete={handleDelete}
    />
  );

  const unchecked = items.filter(i=>!i.checked);
  const checked   = items.filter(i=>i.checked);

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:14 }}>
        <h1 style={{ fontSize:20, fontWeight:700, margin:0 }}>Lista della spesa</h1>
        <button onClick={() => { setEditItem(null); setView("add"); }} style={{ background:"none", border:"none", cursor:"pointer" }}>
          <Icon d={icons.plus} size={20} />
        </button>
      </div>
      <SearchBar placeholder="Cerca prodotto..." />
      <div style={{ flex:1, overflowY:"auto" }}>
        {unchecked.map(item => (
          <ShoppingRow key={item.id} item={item} onToggle={toggle}
            onEdit={() => { setEditItem(item); setView("edit"); }} />
        ))}
        {checked.length > 0 && (
          <>
            <div style={{ fontSize:12, color:"#9ca3af", margin:"8px 0 4px", fontWeight:600 }}>
              Acquistati ({checked.length})
            </div>
            {checked.map(item => (
              <ShoppingRow key={item.id} item={item} onToggle={toggle}
                onEdit={() => { setEditItem(item); setView("edit"); }} />
            ))}
          </>
        )}
        <div style={{ height:16 }} />
      </div>
      <div style={{ display:"flex", gap:8, paddingTop:12, flexShrink:0 }}>
        <button style={{ flex:1, padding:"10px", border:"1px solid #e5e7eb", borderRadius:8, background:"#fff", fontSize:12, cursor:"pointer", fontFamily:"inherit" }}>
          Genera da piano pasti
        </button>
        <button onClick={() => setItems(prev=>prev.filter(i=>!i.checked))}
          style={{ flex:1, padding:"10px", border:"1px solid #e5e7eb", borderRadius:8, background:"#fff", fontSize:12, cursor:"pointer", fontFamily:"inherit" }}>
          Rimuovi acquistati
        </button>
      </div>
    </div>
  );
}

function ShoppingRow({ item, onToggle, onEdit }) {
  return (
    <div style={{ display:"flex", alignItems:"center", gap:10, padding:"10px 0", borderBottom:"1px solid #f3f4f6" }}>
      <div onClick={() => onToggle(item.id)} style={{
        width:18, height:18, borderRadius:4, flexShrink:0, cursor:"pointer",
        border: item.checked ? "none" : "2px solid #d1d5db",
        background: item.checked ? "#111" : "transparent",
        display:"flex", alignItems:"center", justifyContent:"center",
      }}>
        {item.checked && <Icon d={icons.check} size={12} stroke="#fff" strokeWidth={3} />}
      </div>
      <div style={{ flex:1 }}>
        <div style={{ fontSize:14, fontWeight:600,
          textDecoration: item.checked ? "line-through" : "none",
          color: item.checked ? "#9ca3af" : "#111" }}>{item.name}</div>
        <div style={{ fontSize:12, color:"#9ca3af" }}>{item.qty} {item.unit}</div>
      </div>
      <button onClick={onEdit} style={{ background:"none", border:"none", cursor:"pointer", padding:"4px" }}>
        <Icon d={icons.dots} size={16} />
      </button>
    </div>
  );
}

// ─── SCREEN 4: DISPENSA ───────────────────────────────────────────────────────
function AddEditPantryForm({ item, onBack, onSave, onDelete }) {
  const isEdit = !!item;
  const [name, setName] = useState(item?.name || "");
  const [qty,  setQty]  = useState(item?.qty  || "");
  const [unit, setUnit] = useState(item?.unit || "g");
  const [cat,  setCat]  = useState(item?.cat  || "Altro");
  const [exp,  setExp]  = useState(item?.exp  || "");
  const [status,setStatus] = useState(item?.status || "ok");

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader title={isEdit ? "Modifica prodotto" : "Aggiungi prodotto"} onBack={onBack} rightAction={<CheckIcon />} />
      <div style={{ flex:1, overflowY:"auto" }}>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Nome prodotto</label>
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="Es. Latte"
            style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
        </div>
        <div style={{ display:"flex", gap:8 }}>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Quantità</label>
            <input value={qty} onChange={e=>setQty(e.target.value)} placeholder="Es. 1"
              style={{ width:"100%", boxSizing:"border-box", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }} />
          </div>
          <div style={{ flex:1 }}>
            <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Unità di misura</label>
            <select value={unit} onChange={e=>setUnit(e.target.value)}
              style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
              {["g","kg","ml","L","pz","confezione"].map(u=><option key={u}>{u}</option>)}
            </select>
          </div>
        </div>
        <div style={{ marginBottom:14, marginTop:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Categoria</label>
          <select value={cat} onChange={e=>setCat(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            {["Latticini","Cereali","Verdure","Frutta","Carne","Pesce","Uova","Condimenti","Altro"].map(c=><option key={c}>{c}</option>)}
          </select>
        </div>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Data di scadenza</label>
          <div style={{ display:"flex", alignItems:"center", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, justifyContent:"space-between" }}>
            <input value={exp} onChange={e=>setExp(e.target.value)} placeholder="GG/MM/AAAA"
              style={{ border:"none", outline:"none", fontSize:13, fontFamily:"inherit", flex:1 }} />
            <Icon d={icons.calendar} size={16} />
          </div>
        </div>
        <div style={{ marginBottom:14 }}>
          <label style={{ fontSize:12, fontWeight:600, color:"#374151", display:"block", marginBottom:5 }}>Stato</label>
          <select value={status} onChange={e=>setStatus(e.target.value)}
            style={{ width:"100%", padding:"9px 12px", border:"1px solid #e5e7eb", borderRadius:8, fontSize:13, fontFamily:"inherit", outline:"none" }}>
            <option value="ok">OK</option>
            <option value="scadenza">In scadenza</option>
            <option value="esaurimento">In esaurimento</option>
          </select>
        </div>
        <SaveBtn onClick={() => onSave({ name, qty, unit, cat, exp, status })} />
        {isEdit && <DangerBtn label="Rimuovi dalla dispensa" onClick={() => onDelete(item.id)} />}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

function ScreenDispensa() {
  const [items,    setItems]    = useState(INIT_PANTRY);
  const [filter,   setFilter]   = useState("tutti");
  const [view,     setView]     = useState("list");
  const [editItem, setEditItem] = useState(null);

  const handleSave = (data) => {
    if (editItem) {
      setItems(prev => prev.map(i => i.id===editItem.id ? {...i,...data} : i));
    } else {
      setItems(prev => [...prev, { id:Date.now(), ...data }]);
    }
    setView("list");
  };
  const handleDelete = (id) => {
    setItems(prev => prev.filter(i => i.id!==id));
    setView("list");
  };

  if (view==="add" || view==="edit") return (
    <AddEditPantryForm
      item={view==="edit" ? editItem : null}
      onBack={() => setView("list")}
      onSave={handleSave}
      onDelete={handleDelete}
    />
  );

  const filtered = filter==="tutti" ? items
    : filter==="scadenza"    ? items.filter(i=>i.status==="scadenza")
    : items.filter(i=>i.status==="esaurimento");

  const warnCount = items.filter(i=>i.status!=="ok").length;

  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:14 }}>
        <h1 style={{ fontSize:20, fontWeight:700, margin:0 }}>Dispensa</h1>
        <button onClick={() => { setEditItem(null); setView("add"); }} style={{ background:"none", border:"none", cursor:"pointer" }}>
          <Icon d={icons.plus} size={20} />
        </button>
      </div>

      {warnCount > 0 && (
        <div style={{ display:"flex", alignItems:"center", gap:8, padding:"9px 12px", background:"#fef3c7",
          borderRadius:8, marginBottom:10, fontSize:12, color:"#92400e" }}>
          <Icon d={icons.warn} size={16} stroke="#92400e" />
          <span>{warnCount} prodott{warnCount===1?"o":"i"} da controllare</span>
        </div>
      )}

      <SearchBar placeholder="Cerca prodotto..." />
      <div style={{ display:"flex", gap:6, marginBottom:12, overflowX:"auto" }}>
        {[["tutti","Tutti"],["scadenza","In scadenza"],["esaurimento","In esaurimento"]].map(([val,label])=>(
          <Chip key={val} label={label} active={filter===val} onClick={()=>setFilter(val)} />
        ))}
      </div>
      <div style={{ flex:1, overflowY:"auto" }}>
        {filtered.map(item => {
          const st = STATUS_COLORS[item.status];
          return (
            <Card key={item.id} style={{ display:"flex", alignItems:"center", gap:10 }}
              onClick={() => { setEditItem(item); setView("edit"); }}>
              <div style={{ width:42, height:42, background:"#f3f4f6", borderRadius:8, flexShrink:0,
                display:"flex", alignItems:"center", justifyContent:"center", color:"#d1d5db" }}>
                <Icon d={icons.pantry} size={18} />
              </div>
              <div style={{ flex:1 }}>
                <div style={{ fontWeight:600, fontSize:13 }}>{item.name}</div>
                <div style={{ fontSize:12, color:"#6b7280" }}>{item.qty} {item.unit}</div>
                {item.exp && <div style={{ fontSize:11, color:"#9ca3af" }}>Scade: {item.exp}</div>}
              </div>
              <span style={{ padding:"3px 8px", borderRadius:12, background:st.bg, color:st.text, fontSize:11, whiteSpace:"nowrap" }}>
                {st.label}
              </span>
            </Card>
          );
        })}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

// ─── SCREEN 5: STATISTICHE ────────────────────────────────────────────────────
const BAR_DATA = [
  { label:"Pasta",      pct:85 },
  { label:"Pomodori",   pct:60 },
  { label:"Uova",       pct:45 },
  { label:"Latte",      pct:30 },
  { label:"Basilico",   pct:18 },
];

const PIE_DATA = [
  { label:"Pasta",     pct:40, color:"#111" },
  { label:"Secondi",   pct:25, color:"#6b7280" },
  { label:"Insalate",  pct:20, color:"#9ca3af" },
  { label:"Zuppe",     pct:10, color:"#d1d5db" },
  { label:"Altro",     pct:5,  color:"#e5e7eb" },
];

function PieChart() {
  let cum = 0;
  const cx=60, cy=60, r=50;
  const slices = PIE_DATA.map(({ pct, color }) => {
    const s = cum; cum += pct;
    const a1 = (s/100)*2*Math.PI - Math.PI/2;
    const a2 = (cum/100)*2*Math.PI - Math.PI/2;
    const x1=cx+r*Math.cos(a1), y1=cy+r*Math.sin(a1);
    const x2=cx+r*Math.cos(a2), y2=cy+r*Math.sin(a2);
    return { d:`M${cx},${cy} L${x1},${y1} A${r},${r} 0 ${pct>50?1:0},1 ${x2},${y2} Z`, color };
  });
  return (
    <svg width={120} height={120} viewBox="0 0 120 120">
      {slices.map((s,i) => <path key={i} d={s.d} fill={s.color} stroke="#fff" strokeWidth={1.5} />)}
    </svg>
  );
}

function DetailedStats({ onBack }) {
  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <SubHeader title="Statistiche dettagliate" onBack={onBack} />
      <div style={{ flex:1, overflowY:"auto" }}>
        <Card>
          <strong style={{ fontSize:13, display:"block", marginBottom:10 }}>Ingredienti più usati</strong>
          {BAR_DATA.map(({ label, pct }) => (
            <div key={label} style={{ display:"flex", alignItems:"center", gap:8, marginBottom:8 }}>
              <span style={{ fontSize:12, width:72, flexShrink:0 }}>{label}</span>
              <div style={{ flex:1, background:"#f3f4f6", borderRadius:4, height:8 }}>
                <div style={{ width:`${pct}%`, background:"#111", height:8, borderRadius:4 }} />
              </div>
              <span style={{ fontSize:11, color:"#6b7280", width:28, textAlign:"right" }}>{pct}%</span>
            </div>
          ))}
        </Card>
        <Card>
          <strong style={{ fontSize:13, display:"block", marginBottom:10 }}>Distribuzione per categoria</strong>
          <div style={{ display:"flex", gap:12, alignItems:"center" }}>
            <PieChart />
            <div style={{ flex:1 }}>
              {PIE_DATA.map(({ label, pct, color }) => (
                <div key={label} style={{ display:"flex", alignItems:"center", gap:6, marginBottom:6 }}>
                  <div style={{ width:10, height:10, borderRadius:2, background:color, border:"1px solid #e5e7eb", flexShrink:0 }} />
                  <span style={{ fontSize:11, flex:1 }}>{label}</span>
                  <span style={{ fontSize:11, fontWeight:600 }}>{pct}%</span>
                </div>
              ))}
            </div>
          </div>
        </Card>
        <Card>
          <strong style={{ fontSize:13, display:"block", marginBottom:10 }}>Pasti pianificati per giorno</strong>
          {WEEK_DAYS.slice(0,5).map((day, i) => (
            <div key={day} style={{ display:"flex", alignItems:"center", gap:8, marginBottom:8 }}>
              <span style={{ fontSize:12, width:80, flexShrink:0 }}>{day.slice(0,3)}</span>
              <div style={{ flex:1, background:"#f3f4f6", borderRadius:4, height:8 }}>
                <div style={{ width:`${[100,67,33,0,67][i]}%`, background:"#111", height:8, borderRadius:4 }} />
              </div>
              <span style={{ fontSize:11, color:"#6b7280", width:20, textAlign:"right" }}>{[3,2,1,0,2][i]}</span>
            </div>
          ))}
        </Card>
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

const STAT_CARDS = [
  { icon:icons.bookmark, label:"Ricette salvate",                        value:"24" },
  { icon:icons.calendar, label:"Pasti pianificati questa settimana",     value:"12" },
  { icon:icons.clock,    label:"Prodotti in scadenza nei prossimi 7 gg", value:"4"  },
  { icon:icons.pie,      label:"Categoria più usata",                    value:"Pasta" },
  { icon:icons.clock,    label:"Tempo medio di preparazione",            value:"28 min" },
];

function ScreenStatistiche() {
  const [detail, setDetail] = useState(false);
  if (detail) return <DetailedStats onBack={() => setDetail(false)} />;
  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      <h1 style={{ fontSize:20, fontWeight:700, margin:"0 0 14px" }}>Statistiche</h1>
      <div style={{ flex:1, overflowY:"auto" }}>
        {STAT_CARDS.map(({ icon, label, value }) => (
          <Card key={label} style={{ display:"flex", gap:14, alignItems:"center", cursor:"pointer" }}
            onClick={() => setDetail(true)}>
            <div style={{ width:40, height:40, background:"#f3f4f6", borderRadius:10,
              display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0 }}>
              <Icon d={icon} size={20} />
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontSize:12, color:"#6b7280", marginBottom:2 }}>{label}</div>
              <div style={{ fontSize:24, fontWeight:700, lineHeight:1 }}>{value}</div>
            </div>
            <Icon d={icons.chevRight} size={16} />
          </Card>
        ))}
        <div style={{ height:16 }} />
      </div>
    </div>
  );
}

// ─── APP ROOT ─────────────────────────────────────────────────────────────────
export default function App() {
  const [activeTab, setActiveTab] = useState("recipes");
  const [recipes, setRecipes]     = useState(INIT_RECIPES);
  const recipeNames = recipes.map(r => r.name);

  return (
    <div style={{
      display:"flex", justifyContent:"center", alignItems:"center",
      minHeight:"100vh", background:"#e8eaed",
      fontFamily:"'DM Sans', 'Segoe UI', system-ui, sans-serif",
    }}>
      <div style={{
        width:375, height:720, background:"#fff", borderRadius:40,
        boxShadow:"0 32px 90px rgba(0,0,0,0.22)", display:"flex", flexDirection:"column",
        overflow:"hidden", position:"relative",
      }}>
        {/* Status Bar */}
        <div style={{ padding:"12px 22px 4px", display:"flex", justifyContent:"space-between",
          fontSize:11, fontWeight:700, flexShrink:0, color:"#111" }}>
          <span>9:41</span>
          <span style={{ display:"flex", gap:6, alignItems:"center" }}>
            <span>●●●</span><span>WiFi</span><span>🔋</span>
          </span>
        </div>

        {/* Main Content */}
        <div style={{ flex:1, overflowY:"auto", padding:"8px 18px 0", position:"relative" }}>
          {activeTab==="recipes"     && <ScreenRicette />}
          {activeTab==="piano"       && <ScreenPiano recipeNames={recipeNames} />}
          {activeTab==="spesa"       && <ScreenSpesa />}
          {activeTab==="dispensa"    && <ScreenDispensa />}
          {activeTab==="statistiche" && <ScreenStatistiche />}
        </div>

        <BottomNav active={activeTab} setActive={setActiveTab} />
      </div>
    </div>
  );
}
