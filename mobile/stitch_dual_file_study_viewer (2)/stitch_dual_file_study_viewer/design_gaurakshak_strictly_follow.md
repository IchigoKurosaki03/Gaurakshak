DESIGN GAURAKSHAK — STRICTLY FOLLOW THE PROVIDED UX PDF

You are a visual UI/UX design tool for an EXISTING GauRakshak Flutter mobile application.

Your task is to redesign the visual interface and UX of GauRakshak.

IMPORTANT:
The file "Cow_Mastitis_App_UI_UX_Analysis.pdf" is the PRIMARY SOURCE OF TRUTH.

STRICTLY FOLLOW THE PDF.

Do not invent product functionality that is not supported by the PDF.
Do not remove the important flows defined by the PDF.
Do not turn this into a generic AI, IoT, veterinary, healthcare, or farming dashboard.

This design will later be implemented in the EXISTING Flutter application.

DO NOT replace Flutter with HTML.
DO NOT generate a web application.
DO NOT redesign the backend.
DO NOT redesign the database.
DO NOT invent APIs.
DO NOT invent ML capabilities.

Only improve the visual design, information hierarchy, usability, and consistency of the existing mobile app.

==================================================
1. PRODUCT
==================================================

App:
GauRakshak

Purpose:
A farmer-focused cow health, milk monitoring, and early mastitis-warning application.

Core idea from the UX document:

Open app
→ identify cow
→ collect milking data
→ AI analyzes data
→ farmer sees a simple health result and what to do next.

The app should feel like a:

FARM ASSISTANT

NOT:

- a complicated IoT control panel
- a laboratory report
- a technical sensor dashboard
- a generic chatbot
- a veterinary hospital management system

The farmer should be able to use the important features with very few taps.

Technical values may exist in secondary areas for advanced users, but must NOT dominate the main experience.

==================================================
2. STRICT USER FLOW
==================================================

Follow this exact product flow from the PDF:

1. App opening
2. Login
3. Farm setup
4. Add cows
5. Complete profile
6. Start milking
7. Sensor session
8. AI analysis
9. Result
10. Dashboard

The visual navigation may allow the farmer to return to the dashboard and access:
- Cows
- Milk
- Alerts
- More

Do NOT reorder the core onboarding flow.

==================================================
3. SPLASH / APP OPENING
==================================================

Follow the PDF concept.

Visual sequence:

Cow grazing
→ farmer milking
→ milk drop falls
→ milk drop expands/transitions
→ app appears

Keep the animation approximately 2–3 seconds.

The splash should communicate the relationship between:
- cow
- farmer
- milk
- GauRakshak

It should feel memorable but fast.

After first use, the experience may transition faster or provide a skip option.

Do not create a long cinematic animation.

==================================================
4. LOGIN
==================================================

Keep login extremely simple.

Use:

GauRakshak logo

"Welcome back"

Mobile number

OTP

Login / Continue

Do NOT request unnecessary information.

The login should feel familiar to Indian smartphone users.

Use large readable inputs and a clear primary button.

==================================================
5. FARM SETUP
==================================================

Follow the PDF exactly.

The first setup should ask only for what is needed to create the farm:

Farm name
Number of cows

Do NOT force a large medical or farm-management form.

Location may exist only as an optional field if already supported by the application.

Keep setup quick.

==================================================
6. ADD COWS
==================================================

The first cow information should be simple.

Required/primary:

Cow name
Cow ID / tag
Breed
Age / date of birth
Basic health status

Support adding multiple cows.

The design should make it easy to register a herd without creating a huge form.

Detailed information can be completed later.

==================================================
7. COMPLETE COW PROFILE
==================================================

The PDF explicitly says detailed information should not be forced during first-time registration.

Optional/later information can include:

Detailed medical history
Full calving history
Vaccination records
Detailed feeding information
Past treatment details

Provide a clear way to:

"Complete profile later"

Do not make the first-time onboarding form overwhelming.

==================================================
8. COW PROFILE — HEART OF THE APP
==================================================

The cow profile is one of the most important screens.

Use the example cow:

Gauri
COW-024

The farmer-selected cow name must be visually prominent.

The technical ID/tag must be smaller.

Follow this visual order:

Cow photo
↓
Cow name
↓
ID/tag
↓
Breed / age
↓
Current health
↓
Mastitis risk
↓
Today's milk
↓
Recent alerts
↓
Timeline / history

The profile should feel like a simple digital record of one cow.

Do not turn it into a technical data sheet.

==================================================
9. COW IDENTIFICATION DURING MILKING
==================================================

This is a critical UX feature.

Use QR / RFID / ear-tag ID as the PRIMARY identification method.

The cow photo is only an additional visual confirmation.

The intended interaction is:

Scan tag
↓
"Gauri verified"
↓
Sensor node connected/assigned
↓
Start Milking
↓
Farmer can put the phone aside

The design must make this sequence extremely obvious.

The current prototype may simulate scanning, but the visual design must be compatible with future real QR/RFID/tag hardware.

Do not make the photo the primary identification method.

==================================================
10. SENSOR / MILKING SESSION
==================================================

Hide technical complexity from the farmer.

The system associates the sensor node with the identified cow for the current milking session.

The system collects readings and uploads them.

If a sensor node is shared, it can later be released for the next session.

The farmer should NOT need to understand:

- sensor protocols
- API requests
- databases
- ESP32
- MQTT
- networking
- raw telemetry

Instead show simple states such as:

Sensor connected
Data collection active
Milking in progress
Session complete

The primary action should be:

"Start Milking"

and later:

"Finish Session"

The farmer should be able to put the phone aside while milking.

==================================================
11. AI ANALYSIS
==================================================

The screen between sensor collection and result should be simple.

Communicate that:

Sensor readings + historical cow information
are being analyzed.

Use language such as:

"Analyzing Gauri's latest milking data..."

Do not expose technical ML processing.

Do not show a laboratory-style model screen.

Do not invent model accuracy.

Do not invent scientific metrics.

==================================================
12. AI / ML RESULT
==================================================

This is the main result screen.

Follow the PDF example.

Show:

Cow Gauri
COW-024

Health:
Healthy / Monitor / Attention

Mastitis risk:
Low / Medium / High

Milk:
8.7 L today

Trend:
Normal / Increasing / Decreasing

Action:
"Continue monitoring"

or:

"Check cow and contact a veterinarian if symptoms are present."

IMPORTANT:

Present the result as an:

EARLY-WARNING / RISK ESTIMATE

NOT a final medical diagnosis.

Never write:

"Mastitis confirmed"

"Definite mastitis"

"Diagnosis confirmed"

"Guaranteed prediction"

The UI must communicate that a high-risk result means the farmer should check the cow and, where appropriate, seek veterinary confirmation.

Do not make the screen look like a laboratory report.

==================================================
13. MAIN FARMER DASHBOARD
==================================================

The dashboard must answer these three questions immediately:

1. How is my herd?
2. Which cows need attention?
3. How is today's milk production?

Include the PDF's required sections:

HERD STATUS

Show:
Total cows
Healthy
Monitor
At Risk

TODAY'S MILK

Show:
Total milk
Simple comparison with previous days

ATTENTION

Show:
Top cows that need checking

RECENT ACTIVITY

Show:
Latest milking sessions
Completed checks

TRENDS

Show simple charts for:
Milk production
Risk changes

Do NOT create a crowded IoT dashboard.

Do NOT fill the dashboard with raw sensor values.

The dashboard should be calm, simple, and actionable.

==================================================
14. ALERTS
==================================================

Alerts must be:

Short
Useful
Actionable

Do NOT use technical messages such as:

"EC threshold exceeded"

Instead explain:

What changed
Which cow
What the farmer should do

Example:

"Gauri needs attention."

"Mastitis risk has increased over the last 2 days."

"Check the cow for signs of udder inflammation and contact a veterinarian if needed."

Do not make alerts frightening.

Do not create unnecessary alert spam.

==================================================
15. COW TIMELINE
==================================================

The timeline should show the story of one cow.

Include:

Milk production
Risk changes
Vaccinations
Calving events
Treatments
Important health notes

Example:

Sep 04
8.7 L milk

Sep 03
Risk increased

Aug 28
Vaccination

Aug 15
Calving

Make the timeline easy to scan.

==================================================
16. BOTTOM NAVIGATION
==================================================

Follow the PDF navigation structure exactly:

HOME
Herd overview, alerts, today's summary

COWS
Search, filter, individual cow profiles

MILK
Milk production and quality trends

ALERTS
Health warnings and actions

MORE
Farm settings, profile completion, devices and records

Do not add unrelated bottom-navigation items.

==================================================
17. UI DESIGN LANGUAGE
==================================================

Strictly follow the PDF's design language.

TYPOGRAPHY

Large, readable text.

Avoid tiny labels.

BUTTONS

Large touch targets.

Use clear words such as:

"Start Milking"
"View Cow"

ICONS

Use familiar icons WITH text.

Never rely on icons alone for important information.

STATUS

Use consistent symbols + text:

Healthy
Monitor
At Risk

Do not communicate important status using color alone.

CHARTS

Keep charts simple.

Show trends instead of many technical lines.

LANGUAGE

Use simple terms.

Design for future local-language support.

Connectivity

Show clear:

Online
Offline
Syncing
Sync complete / pending

because farm connectivity may be unreliable.

ACCESSIBILITY

Use:
- high contrast
- readable fonts
- large touch targets
- minimal typing
- clear labels

==================================================
18. VISUAL STYLE
==================================================

Create a polished, premium but practical visual identity.

The app should feel:

Warm
Trustworthy
Agricultural
Simple
Modern
Human
Practical

Suggested palette:

Deep forest green
Soft cream
Muted mint
Warm neutrals
Amber for Monitor
Red for At Risk

Keep the visual language close to a real agricultural product.

Avoid:

Neon
Futuristic interfaces
Cyberpunk
Excessive gradients
Excessive glassmorphism
Dense dashboards
Tiny text
Laboratory-report styling
Generic enterprise SaaS styling

Use:

Rounded cards
Clear hierarchy
Whitespace
Large readable typography
Simple charts
Familiar icons
Strong primary actions

==================================================
19. PRIORITY — STRICTLY FOLLOW MVP PRIORITIES
==================================================

MUST HAVE:

Login
Farm setup
Cow registration
Cow ID scanning
Sensor/session association
Dashboard
Mastitis-risk result

SHOULD HAVE:

Cow photo
Milk trends
Alerts
Cow timeline
Profile editing

NICE TO HAVE:

Voice guidance
Local-language support
Advanced analytics
Veterinarian access
Automatic reminders

Do NOT let NICE-TO-HAVE features dominate the design.

Do not add new product features outside this scope.

==================================================
20. GAUSAATHI
==================================================

GauSaathi may exist as an in-app assistant, but keep it secondary to the core workflow.

It must feel like a farm assistant connected to GauRakshak data.

It should NOT become a generic ChatGPT-style application.

Possible questions:

"Why is Gauri at high risk?"

"Which cows need attention?"

"How is Gauri's milk production?"

Keep the experience simple.

Do not add social/chat/community features.

==================================================
21. REALISTIC EXAMPLE DATA
==================================================

Use:

Farm:
Shree Krishna Dairy

Cow:
Gauri

ID:
COW-024

Milk:
8.7 L today

Health:
Monitor

Mastitis risk:
High

Trend:
Decreasing

Use realistic farm information.

Do not show ridiculous values.

Do not invent:
99.9% accuracy
100% prediction
guaranteed detection
clinical validation

==================================================
22. IMPORTANT MEDICAL LANGUAGE
==================================================

This is an EARLY-WARNING system.

Never represent the UI as a diagnostic tool.

Use:

"Early-warning risk"

"Risk estimate"

"Needs attention"

"Monitor"

"Check cow"

"Veterinary confirmation"

Avoid:

"Mastitis confirmed"

"Diagnosis"

"Guaranteed"

"Definite infection"

"Prescribed treatment"

Do not include medicine names or dosages.

==================================================
23. OFFLINE / CONNECTIVITY
==================================================

Connectivity status must be visible but subtle.

Support visual states for:

Online
Offline
Sync pending
Syncing
Synced

The farmer should understand the state without technical knowledge.

Do not show technical networking information.

==================================================
24. SCREEN GENERATION ORDER
==================================================

Generate and refine screens in the actual user-flow order.

DO NOT start with the dashboard and then randomly jump around.

Use this order:

1. Splash / App opening
2. Login
3. OTP verification
4. Farm setup
5. Add cows
6. Cow profile
7. Scan / identify cow
8. Sensor / milking session
9. AI analysis
10. AI/ML result
11. Dashboard
12. Alerts
13. Milk trends
14. More / settings
15. GauSaathi

The design system must remain consistent across every screen.

==================================================
25. REFINEMENT RULE
==================================================

After generating each screen, refine it before moving to the next.

Use these principles:

- Less clutter
- Stronger hierarchy
- One obvious primary action
- Large readable text
- Familiar icons + text
- Simple farmer-friendly wording
- Technical information secondary
- Consistent status design
- Consistent cards
- Consistent spacing
- Consistent typography

Do not add functionality during visual refinement.

==================================================
26. FINAL DESIGN SYSTEM
==================================================

After all screens are approved, produce/export the design system.

Include:

Color tokens
Typography
Spacing
Border radius
Buttons
Cards
Inputs
Status indicators
Risk indicators
Alert cards
Navigation
Charts
Timeline
Loading states
Empty states
Offline states
Error states

The design system must be practical to implement in Flutter.

==================================================
27. FINAL PRINCIPLE
==================================================

Follow the central concept from the UX document:

"Scan the cow.
Let the system do the work.
Show the farmer what matters."

The final application should feel simple enough for a dairy farmer,
professional enough for an SIH demonstration,
and practical enough for real farm use.

STRICT FINAL RULE:

The provided Cow_Mastitis_App_UI_UX_Analysis.pdf overrides your assumptions.

If something is not specified in the PDF, prefer simplicity and consistency with the PDF instead of inventing a new feature.

DO NOT redesign the product.
DESIGN THE EXISTING PRODUCT BETTER.