// CodeArena C++ runner wrapper around JSCPP.
// Exposes codeArenaRun(code, input) -> JSON string.
// Runs JSCPP synchronously (no stepping): infinite loops are bounded
// by the caller's wall-clock timeout (worker terminate on web,
// runtime dispose on native). Keep it dependency-free ES5.
function codeArenaRun(code, input, maxSteps) {
  var output = "";
  var OUTPUT_LIMIT = 262144;

  var config = {
    stdio: {
      write: function (s) {
        output += s;
        if (output.length > OUTPUT_LIMIT) {
          throw { arenaError: "OUTPUT_LIMIT" };
        }
      }
    },
    unsigned_overflow: "warn",
    debug: false
  };

  function finish(ok, extra) {
    extra.ok = ok;
    extra.output = output;
    return JSON.stringify(extra);
  }

  var exitcode;
  try {
    exitcode = JSCPP.run(code, input, config);
  } catch (e) {
    if (e && e.arenaError === "OUTPUT_LIMIT") {
      return finish(false, { error: "OUTPUT_LIMIT" });
    }
    var msg = (e && e.message) ? String(e.message) : String(e);
    if (msg.indexOf("Parsing") !== -1 || msg.indexOf("Syntax") !== -1) {
      return finish(false, { error: "PARSE", detail: msg });
    }
    // C++ allows falling off the end of main (implicit return 0); JSCPP doesn't.
    if (/must return a value/i.test(msg)) return finish(true, { exitcode: 0 });
    return finish(false, { error: "RUNTIME", detail: msg });
  }
  return finish(true, { exitcode: (exitcode && exitcode.v) || exitcode || 0 });
}
