{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    window.requestAnimationFrame(function() {
      window.requestAnimationFrame(function() {
        if (window.removeSplashScreen) {
          window.removeSplashScreen();
        }
      });
    });
  }
});
