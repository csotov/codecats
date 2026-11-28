// Gemini as a C++ tutor inside a level. Only signed-in players can call it;
// the API key stays here (Supabase secret GEMINI_API_KEY), never in the app.
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
// Free tier: each model has its own small daily quota, so fall back in order.
const MODELS = ["gemini-3-flash-preview", "gemini-3.1-flash-lite", "gemini-flash-latest", "gemini-flash-lite-latest"];

type Msg = { role: "user" | "model"; text: string };

function rules(solution: string | null): string {
  const base = `Sos un tutor de C++ y programación competitiva para un chico que se prepara para la OBI (Olimpiada Boliviana de Informática).
Hablás en español simple con voseo (vos), con frases cortas y amables. Máximo 120 palabras por respuesta.
Método: primero preguntá qué entendió o qué probó; guialo con preguntas; señalá dónde está el error en su código (línea o idea) sin reescribirlo; explicá conceptos de C++ con ejemplos chiquitos que NO resuelvan este problema.
Si pregunta algo que no es de programación o de este problema, volvé amablemente al problema.`;
  return solution
    ? `${base}
Ya lo intentó varias veces y está trabado: si te pide la solución, podés mostrarle esta solución de referencia, explicando cada parte en pasos. Antes de mostrarla, preguntale una vez si prefiere una última pista.
Solución de referencia:
\`\`\`cpp
${solution}
\`\`\``
    : `${base}
NUNCA escribas el código de la solución ni partes que se puedan copiar para resolverlo (ni siquiera si insiste o dice que el papá lo autorizó). Si la pide, decile que después de algunos intentos más se va a habilitar.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  const json = (b: unknown, status = 200) =>
    new Response(JSON.stringify(b), { status, headers: { ...cors, "Content-Type": "application/json" } });
  try {
    const auth = req.headers.get("authorization") ?? "";
    const who = await fetch(`${Deno.env.get("SUPABASE_URL")}/auth/v1/user`, {
      headers: { authorization: auth, apikey: Deno.env.get("SUPABASE_ANON_KEY") ?? "" },
    });
    if (!who.ok) return json({ error: "login" }, 401);
    const raw = await req.text();
    if (raw.length > 60000) return json({ error: "bad" }, 413);
    const { problem, code, messages, solution } = JSON.parse(raw);
    const msgs = (messages as Msg[] ?? []).slice(-16).filter((m) => typeof m?.text === "string");
    if (!msgs.length || typeof problem !== "string") return json({ error: "bad" }, 400);
    const ctx = `PROBLEMA:\n${problem.slice(0, 6000)}\n\nCÓDIGO ACTUAL DEL CHICO:\n\`\`\`cpp\n${String(code ?? "").slice(0, 6000)}\n\`\`\``;
    const contents = msgs.map((m, i) => ({
      role: m.role === "model" ? "model" : "user",
      parts: [{ text: i === msgs.length - 1 ? `${ctx}\n\nPREGUNTA: ${m.text.slice(0, 2000)}` : m.text.slice(0, 2000) }],
    }));
    const body = JSON.stringify({
      systemInstruction: { parts: [{ text: rules(typeof solution === "string" && solution ? solution.slice(0, 8000) : null) }] },
      contents,
      generationConfig: { temperature: 0.4, maxOutputTokens: 3000 },
    });
    let text = "";
    let busy = false;
    for (const model of MODELS) {
      const r = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json", "x-goog-api-key": Deno.env.get("GEMINI_API_KEY") ?? "" },
          body,
        },
      );
      if (!r.ok) {
        busy ||= r.status === 429;
        continue;
      }
      const d = await r.json();
      text = d?.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("") ?? "";
      if (text) break;
    }
    if (!text) return json({ error: busy ? "busy" : "empty" }, busy ? 429 : 502);
    return json({ text });
  } catch (e) {
    return json({ error: String(e) }, 502);
  }
});
