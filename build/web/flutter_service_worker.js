'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "02c09988f6be3c231791a2bcc0af0b74",
"version.json": "1a1b0e5c7266883af299ad3515e4665d",
"index.html": "2946ea72f82f4400777c41555b3ebfff",
"/": "2946ea72f82f4400777c41555b3ebfff",
"main.dart.js": "0c1eebcb5789622e4279aa5d6df58bac",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "f976201962078d162ef8afe34430e222",
"assets/AssetManifest.json": "6ffdb1d886db07359b495cefbd48f0c9",
"assets/NOTICES": "b19ac63c0a48bd5411fac082bd917495",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "9adc604d0991fa0de5c114dcaed1133c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "270e3782ec85f38645c028fe8e75db7c",
"assets/fonts/MaterialIcons-Regular.otf": "07fbfc50107b43c52a2e034cb0ee3e4c",
"assets/assets/branding/logo.svg": "993a1b33e6f09c1b5ce4433dcb873a2d",
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
"assets/private_assets/ensayos/ensayo_2/questions/q_12.png": "05c55e049ee315b232ec1ec0ebe33d10",
"assets/private_assets/ensayos/ensayo_2/questions/q_06.png": "268936295160f7dbc8d51985f438e3a3",
"assets/private_assets/ensayos/ensayo_2/questions/q_07.png": "8d77f8301280ae49c5b8e9821d08ee91",
"assets/private_assets/ensayos/ensayo_2/questions/q_13.png": "41b108774ec5b62c1be54147bfab00ca",
"assets/private_assets/ensayos/ensayo_2/questions/q_39.png": "854ec2a23a2b39557616baa2fe3af70d",
"assets/private_assets/ensayos/ensayo_2/questions/q_05.png": "8a0e19d57095a1ffc7f6b2de1ed3edba",
"assets/private_assets/ensayos/ensayo_2/questions/q_11.png": "98f1a9b79be39dc2561be7e41a3608a0",
"assets/private_assets/ensayos/ensayo_2/questions/q_10.png": "42f0ec6178a8d6f2fbca6267b2d2ce14",
"assets/private_assets/ensayos/ensayo_2/questions/q_04.png": "1ba16be206f60077d7b16af6e79e717c",
"assets/private_assets/ensayos/ensayo_2/questions/q_38.png": "b70081733be86ecb950d9f47af3c8b02",
"assets/private_assets/ensayos/ensayo_2/questions/q_14.png": "ebb14d5c8a1e2d16f91a9765c55d9285",
"assets/private_assets/ensayos/ensayo_2/questions/q_28.png": "3ef42accea590066ff48cdfadf9b0e04",
"assets/private_assets/ensayos/ensayo_2/questions/q_29.png": "3c0ab7070be9dd767614dd1f43492fa5",
"assets/private_assets/ensayos/ensayo_2/questions/q_15.png": "e9797f0795a620ecda280fad0b8f8d25",
"assets/private_assets/ensayos/ensayo_2/questions/q_01.png": "9611eb8c0b1bda4345157fabf3f81187",
"assets/private_assets/ensayos/ensayo_2/questions/q_17.png": "d566ee4b6948a2414e0ba9f15113571e",
"assets/private_assets/ensayos/ensayo_2/questions/q_03.png": "9d2068177a3aebc6832ab9b593c717d8",
"assets/private_assets/ensayos/ensayo_2/questions/q_02.png": "2d8ac3b8ca8a82c1cb1e27942538ac60",
"assets/private_assets/ensayos/ensayo_2/questions/q_16.png": "048464bafbb4dd3e0a3626481c5ef425",
"assets/private_assets/ensayos/ensayo_2/questions/q_59.png": "0f02a6a44f4c2d4c36baaa98e387ccbe",
"assets/private_assets/ensayos/ensayo_2/questions/q_65.png": "8aac83911269315211c0446766488e2d",
"assets/private_assets/ensayos/ensayo_2/questions/q_64.png": "d20418c0daa2c692baafeb8959d17810",
"assets/private_assets/ensayos/ensayo_2/questions/q_58.png": "8776dbfb5407d5efea0a0eec2ac37550",
"assets/private_assets/ensayos/ensayo_2/questions/q_63.png": "a1df32a68926fe68cffdad5fc05cf78f",
"assets/private_assets/ensayos/ensayo_2/questions/q_62.png": "eebc0b4d1c30640ab707cdc1a3268d5a",
"assets/private_assets/ensayos/ensayo_2/questions/q_60.png": "6ffdf2d89d8f5fa4be405640770bdbf5",
"assets/private_assets/ensayos/ensayo_2/questions/q_48.png": "e325c03558e4c9dcdb37b1e0f2871829",
"assets/private_assets/ensayos/ensayo_2/questions/q_49.png": "fbbedab793c45c266d9958ad2f08199f",
"assets/private_assets/ensayos/ensayo_2/questions/q_61.png": "143c3f47278bd90cb6b9214157925ee4",
"assets/private_assets/ensayos/ensayo_2/questions/q_50.png": "530158e39cb15614d61eeb82be51fa3e",
"assets/private_assets/ensayos/ensayo_2/questions/q_44.png": "9bcd25f55315cdd151f6bc5498d1b03c",
"assets/private_assets/ensayos/ensayo_2/questions/q_45.png": "07fbc11c18c77242d6e00079f6f77b69",
"assets/private_assets/ensayos/ensayo_2/questions/q_51.png": "fd588ac17cd4070f73bacd9593607a9c",
"assets/private_assets/ensayos/ensayo_2/questions/q_47.png": "a7cbc00956bca27f712e974e51f14c27",
"assets/private_assets/ensayos/ensayo_2/questions/q_53.png": "d14932bb1640008787173aae6d2e7c42",
"assets/private_assets/ensayos/ensayo_2/questions/q_52.png": "af483885ae4ba50e00024b765ec03c68",
"assets/private_assets/ensayos/ensayo_2/questions/q_46.png": "101762a5205ebb114282659e9783a7bc",
"assets/private_assets/ensayos/ensayo_2/questions/q_42.png": "61c1b12d48ba273359f8fbe593ef3a0b",
"assets/private_assets/ensayos/ensayo_2/questions/q_56.png": "783c01401c2751d1691d77176659a042",
"assets/private_assets/ensayos/ensayo_2/questions/q_57.png": "2b474568a5c5dbd6843eeaf7bd49e1bb",
"assets/private_assets/ensayos/ensayo_2/questions/q_43.png": "5015604a026e20f8fd96ee078ff7cf0f",
"assets/private_assets/ensayos/ensayo_2/questions/q_55.png": "311e33c666b8f544602ef5e8fd879c59",
"assets/private_assets/ensayos/ensayo_2/questions/q_41.png": "a51eecb0634d66aa7f888768e71d97c3",
"assets/private_assets/ensayos/ensayo_2/questions/q_40.png": "9d4d6107d7c1bfc7c7be81927a7d7281",
"assets/private_assets/ensayos/ensayo_2/questions/q_54.png": "d29acd0a4050ab2adabe5def55fabfc4",
"assets/private_assets/ensayos/ensayo_2/questions/q_33.png": "7329e1438c0919e003d95601f30fe6bb",
"assets/private_assets/ensayos/ensayo_2/questions/q_27.png": "fe7ac0d299098094b518c7a729e5858e",
"assets/private_assets/ensayos/ensayo_2/questions/q_26.png": "13fd467731bdc6c9111dd234fb4a1b9e",
"assets/private_assets/ensayos/ensayo_2/questions/q_32.png": "62aee25ee4cd3c1aac1da11415d53254",
"assets/private_assets/ensayos/ensayo_2/questions/q_18.png": "3e3b47bd003af27626883b87c80a958e",
"assets/private_assets/ensayos/ensayo_2/questions/q_24.png": "a5910d85e5f0a844548ff8f23d515804",
"assets/private_assets/ensayos/ensayo_2/questions/q_30.png": "763e201dc98bf11181f9ab5c6ac048a4",
"assets/private_assets/ensayos/ensayo_2/questions/q_31.png": "793740d4bca45e8be5b52774db32df06",
"assets/private_assets/ensayos/ensayo_2/questions/q_25.png": "2f5f8096ec6545e01b9310b1a8ef3188",
"assets/private_assets/ensayos/ensayo_2/questions/q_19.png": "f165452f5c0f179e0e71f2e66abb6642",
"assets/private_assets/ensayos/ensayo_2/questions/q_21.png": "14d0400bbae1534d6445e13fc99b6133",
"assets/private_assets/ensayos/ensayo_2/questions/q_35.png": "4116bb3482f13b4ec220e3a7df7c0122",
"assets/private_assets/ensayos/ensayo_2/questions/q_09.png": "f11b0eaeefb7c5c2b8d0103402066162",
"assets/private_assets/ensayos/ensayo_2/questions/q_08.png": "c72ab435c7874e3079d51c2ddc7a33da",
"assets/private_assets/ensayos/ensayo_2/questions/q_34.png": "73f2a4efb0284d0fd30626d51b51bad7",
"assets/private_assets/ensayos/ensayo_2/questions/q_20.png": "24456cd87014ce7bda11f59998889c4e",
"assets/private_assets/ensayos/ensayo_2/questions/q_36.png": "4924b5fa63f2d1ba4c9892dbc2e41610",
"assets/private_assets/ensayos/ensayo_2/questions/q_22.png": "a9a8d4966c003dfef552f271b626071d",
"assets/private_assets/ensayos/ensayo_2/questions/q_23.png": "a5ac2e32a2bb833b9e0041081ca769fd",
"assets/private_assets/ensayos/ensayo_2/questions/q_37.png": "62d8c288be2af6d77ef8090e9a52eee6",
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
