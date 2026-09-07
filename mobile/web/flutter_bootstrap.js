{{flutter_js}}
{{flutter_build_config}}

// Cache-busting explícito para forçar atualização em PWAs instalados
if (window._flutter && window._flutter.buildConfig && window._flutter.buildConfig.builds) {
  window._flutter.buildConfig.builds.forEach(function(build) {
    if (build.mainJsPath) {
      build.mainJsPath = build.mainJsPath + '?v=1.0.3';
    }
  });
}

_flutter.loader.load();
