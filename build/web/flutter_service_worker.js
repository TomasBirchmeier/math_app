'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "c319166edfca72ba7c26b8cec9d520ea",
"version.json": "1a1b0e5c7266883af299ad3515e4665d",
"index.html": "2d5c89f7614b92a4dae8851693788d0a",
"/": "2d5c89f7614b92a4dae8851693788d0a",
"main.dart.js": "b1e7a4d3f4306293eaafb1f01d6453f8",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "f976201962078d162ef8afe34430e222",
"assets/AssetManifest.json": "e28e624ee3f9e8d3769c98f03e6902a2",
"assets/NOTICES": "5a3976e51a6ba9f7c4bad3286fe86198",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "82e405734adb3b31ff0750b0b38ed3d2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "e40fdda271b52dc5ad3ac5ee5d173535",
"assets/fonts/MaterialIcons-Regular.otf": "72cce1184247056bc04458b40c2c81cc",
"assets/assets/ensayos/questions/q_12.png": "587a1affd903b5d93c9f79830e159c15",
"assets/assets/ensayos/questions/q_06.png": "1925726dffb180f5addbb03c6c4613f0",
"assets/assets/ensayos/questions/q_07.png": "755af7f5f449379cc23e6f75c76144e3",
"assets/assets/ensayos/questions/q_13.png": "8df36100b115c41f06a8e62fdc3abd5f",
"assets/assets/ensayos/questions/q_39.png": "2a858f411e1a21a73913ac3a090bd358",
"assets/assets/ensayos/questions/q_05.png": "3c6df919542c76b1174c66b38459f766",
"assets/assets/ensayos/questions/q_11.png": "46096c87644d874ee6699a312c756024",
"assets/assets/ensayos/questions/q_10.png": "51bb856d2dfc0fc2c3f410199c52e89a",
"assets/assets/ensayos/questions/q_04.png": "01442797b30684274a8612e1bbb3febe",
"assets/assets/ensayos/questions/q_38.png": "815fda5fe5f545312a9ecef620d27aee",
"assets/assets/ensayos/questions/q_14.png": "721e720caaf562508fcfa4e7f2d47f3b",
"assets/assets/ensayos/questions/q_28.png": "0f380d568ec758417693d04ba7535c38",
"assets/assets/ensayos/questions/q_29.png": "fbc9cf50065333ed0c276f97f05fd345",
"assets/assets/ensayos/questions/q_15.png": "b577fe5891c436d4555b678f91a18ae2",
"assets/assets/ensayos/questions/q_01.png": "b960df86b573da6d007d2fdc07d22411",
"assets/assets/ensayos/questions/q_17.png": "3eb1c5a249afa10eeb465dda41395c23",
"assets/assets/ensayos/questions/q_03.png": "f087ae9a71d1f91a774cc8b3577f9e52",
"assets/assets/ensayos/questions/q_02.png": "5ad944299164687670bfaad9594cd0be",
"assets/assets/ensayos/questions/q_16.png": "04c3954e0946db4d6b1ac64cc0374816",
"assets/assets/ensayos/questions/q_59.png": "9dc5f0b98631413932888e2b768da9db",
"assets/assets/ensayos/questions/q_65.png": "7ad01122426ec20799cede459a345407",
"assets/assets/ensayos/questions/q_64.png": "b7334bd782303471e0e11b42a1a656fd",
"assets/assets/ensayos/questions/q_58.png": "9591ebc34b114698d75a76c03698d620",
"assets/assets/ensayos/questions/q_63.png": "a7f121a2b2b0b8e3e4b393c893f30d7e",
"assets/assets/ensayos/questions/q_62.png": "c51ed23b8f6e8752bea6f5646e419a02",
"assets/assets/ensayos/questions/q_60.png": "df6e7025151dac656b73ff756876968c",
"assets/assets/ensayos/questions/q_48.png": "aaa2e0b642d39625ec9f9aa7729f8258",
"assets/assets/ensayos/questions/q_49.png": "f82e32baa0d3aff55a6b55ea0367c0b3",
"assets/assets/ensayos/questions/q_61.png": "ddb7f8241ef03c906a0f94c5b9641be3",
"assets/assets/ensayos/questions/q_50.png": "4a793b74040f0afe980b3389cdd72762",
"assets/assets/ensayos/questions/q_44.png": "31dd42dd498e83e6e55d3ac184cb6ea7",
"assets/assets/ensayos/questions/q_45.png": "e9a8e5e050c6292389d0298994b264c8",
"assets/assets/ensayos/questions/q_51.png": "d9137da7bab8c7261e8b03cea0b71f15",
"assets/assets/ensayos/questions/q_47.png": "2672b38c3a563eea22c79b76db6e8ff7",
"assets/assets/ensayos/questions/q_53.png": "282b1bcf99c146d963f69f93afd01bd8",
"assets/assets/ensayos/questions/q_52.png": "c37138306abc2584a8b14e4896483c9f",
"assets/assets/ensayos/questions/q_46.png": "919476b78e6195d61cadc69c2b704a56",
"assets/assets/ensayos/questions/q_42.png": "916dfd5dd0772de2e502dea6d6d257e1",
"assets/assets/ensayos/questions/q_56.png": "1602310cbca7044dc95582d52b71d334",
"assets/assets/ensayos/questions/q_57.png": "62695fc31700457a2248dfea8079ee9e",
"assets/assets/ensayos/questions/q_43.png": "46868765ba4f7e9b420d98d2e4f62509",
"assets/assets/ensayos/questions/q_55.png": "a815cf8aaf847585f9aa752e3f5b7107",
"assets/assets/ensayos/questions/q_41.png": "3c5766c972e2af0a7ac6fb3de1ca8fd7",
"assets/assets/ensayos/questions/q_40.png": "7b43da48879d4549fcb109561cd6295d",
"assets/assets/ensayos/questions/q_54.png": "9ccc85d81d93140fc5d6b74504c9524c",
"assets/assets/ensayos/questions/q_33.png": "0180ea15ce1280f14f7e8ada88043abd",
"assets/assets/ensayos/questions/q_27.png": "2cf64ef7eb3e52b00a427d8f0d750fb2",
"assets/assets/ensayos/questions/q_26.png": "047606c741db357b80f453d41cc39954",
"assets/assets/ensayos/questions/q_32.png": "14da98bcf1bb48790152e0169335ebbf",
"assets/assets/ensayos/questions/q_18.png": "d41c246984b05e55225b0eba0cb187db",
"assets/assets/ensayos/questions/q_24.png": "8372021cbda7f11d551d3392b72267fa",
"assets/assets/ensayos/questions/q_30.png": "84615fa72ce32948a6ac588ef07a7b2a",
"assets/assets/ensayos/questions/q_31.png": "4ae7375e6cf88ac3d9f4cb1203e41467",
"assets/assets/ensayos/questions/q_25.png": "f94b00bc0b4e617be3ab9e34ef7b1bc1",
"assets/assets/ensayos/questions/q_19.png": "3dc1e10b1ebc0081113a6e45ba280121",
"assets/assets/ensayos/questions/q_21.png": "01a7245c4efeadbaf505169e10a244cf",
"assets/assets/ensayos/questions/q_35.png": "4c0bdadc4f2c756c90c0a816924b6a26",
"assets/assets/ensayos/questions/q_09.png": "08acfa09d7bff2a390b68743f7d5b86d",
"assets/assets/ensayos/questions/q_08.png": "2c3599d3603df0835ec41d604c87b74f",
"assets/assets/ensayos/questions/q_34.png": "79b9af8124a6b65c31517636d2a8df6c",
"assets/assets/ensayos/questions/q_20.png": "da5449d05109ee0c479f65c3aaa7eff3",
"assets/assets/ensayos/questions/q_36.png": "8570b0e0b5037861e359f7b224c9d9e1",
"assets/assets/ensayos/questions/q_22.png": "cd57b644c39918b21c7d09e7ff2d3cf1",
"assets/assets/ensayos/questions/q_23.png": "604922365477c2be7d2a0e407afe8da3",
"assets/assets/ensayos/questions/q_37.png": "0a81c9e9a53d942dfce9ffd7d1291c56",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
