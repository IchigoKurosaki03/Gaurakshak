# Production UI boundary

`lib/main.dart` starts `ui/app.dart`, which is the only production entry point.
Its active route is:

```text
Splash → Login → Farm setup → Home tabs
                       ├─ Home/dashboard
                       ├─ Cows → Cow profile → Scan/milking
                       ├─ Cow health
                       ├─ Milk monitoring
                       └─ More/settings/devices/reviews
```

The reusable production widgets live under `lib/ui/widgets/`, while the
feature screens are under `lib/screens/`. `lib/screens/stitch_app.dart` is a
reference-only earlier Stitch prototype and is not reachable from the app
entry point. `lib/screens/onboarding_screens.dart` remains active only because
the current cow-registration flow reuses `AddCowScreen` from that file.

Do not edit the reference prototype when changing production behavior. Before
removing it, run a repository-wide reference search and update the design study
documentation so the source of truth stays unambiguous.
