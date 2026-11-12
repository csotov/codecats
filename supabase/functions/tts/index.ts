// Speaks a Spanish line with Jorge (es-MX) for lines not pre-recorded in
// web/voz/ (they carry names, numbers or level titles).
import { synth } from "./edge_tts.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  try {
    const { text } = await req.json();
    if (typeof text !== "string" || !text.trim() || text.length > 1500) {
      return new Response("bad text", { status: 400, headers: cors });
    }
    const mp3 = await synth(text.trim());
    return new Response(mp3, {
      headers: { ...cors, "Content-Type": "audio/mpeg", "Cache-Control": "public, max-age=86400" },
    });
  } catch (e) {
    return new Response(String(e), { status: 502, headers: cors });
  }
});
