# Video "Así es el examen" (assets/video/examen_obi.mp4)

The app plays the walkthrough by itself at `?demo=obi` (`ObiSimScreen(demo: true)`),
printing `DEMO_SEG <i>` / `DEMO_END` to the console. To re-record:

1. Narration: one line per segment in `narracion.txt`. Generate `s00.mp3…` with
   edge-tts voice `es-MX-JorgeNeural` (rate -5%) and put their lengths (ms) in
   `_demoMs` in lib/ui/obi_sim_screen.dart.
2. `flutter build web --release --output build/rec`, serve it, and record
   1280x720 with Playwright (`record_video_dir`, headless chromium with
   `--use-angle=swiftshader`), saving the console time of each `DEMO_SEG`
   (use `page.wait_for_timeout`, not `time.sleep`, or events arrive late).
3. Mix: each clip at its `DEMO_SEG` time (`adelay` + `amix`), burn sentence
   subtitles (`subtitles=` filter) and overlay assets/profe.png bottom-right;
   encode H.264 CRF 30, AAC 64k mono, `+faststart`.
