#!/usr/bin/env python3
"""MAT Kenya Mock Data Generator - Generates realistic route and fare data for major Kenyan cities"""
import json, random, math

# Real Kenyan city locations (latitude, longitude)
KENYAN_LOCATIONS = {
    # Nairobi
    "Nairobi CBD": (-1.2864, 36.8172), "Westlands": (-1.2676, 36.8070),
    "Karen": (-1.3197, 36.7074), "Ngong": (-1.3525, 36.6526),
    "Thika": (-1.0332, 37.0871), "Embakasi": (-1.3197, 36.8947),

    # Mombasa
    "Mombasa Town": (-4.0435, 39.6682), "Nyali": (-4.0274, 39.7073),
    "Likoni": (-4.0833, 39.6667), "Bamburi": (-3.9833, 39.7167),

    # Nakuru
    "Nakuru Town": (-0.3031, 36.0800), "Free Area": (-0.2833, 36.0667),
    "Lanet": (-0.2167, 36.0500), "Section 58": (-0.3167, 36.0833),

    # Eldoret
    "Eldoret Town": (0.5143, 35.2698), "Langas": (0.5667, 35.2833),
    "Pioneer": (0.5333, 35.2667), "Elgon View": (0.5000, 35.2833),

    # Kisumu
    "Kisumu Town": (-0.0917, 34.7680), "Kondele": (-0.1000, 34.7500),
    "Mamboleo": (-0.0833, 34.7333), "Manyatta": (-0.1167, 34.7667),
}

# Real routes (origin, destination, intermediates) - Covering major Kenyan cities
REAL_ROUTES = [
    # ========== NAIROBI ROUTES (5) ==========
    # Route 23: CBD to Westlands via Uhuru Highway
    ("Nairobi CBD", "Westlands", ["Uhuru Highway", "Museum Hill", "Parklands", "Sarit Centre"]),

    # Route 111: CBD to Karen via Lang'ata Road
    ("Nairobi CBD", "Karen", ["Nyayo Stadium", "Yaya Centre", "Adams Arcade", "Hardy"]),

    # Route 111: CBD to Ngong via Dagoretti
    ("Nairobi CBD", "Ngong", ["Nyayo Stadium", "Dagoretti Corner", "Riruta", "Uthiru", "Karen Junction"]),

    # Route 45/237: CBD to Thika via Thika Road
    ("Nairobi CBD", "Thika", ["Pangani", "Roysambu", "Kasarani", "Mwiki", "Githurai 45", "Ruiru"]),

    # Route 34/35: CBD to Embakasi via Jogoo Road
    ("Nairobi CBD", "Embakasi", ["Makongeni", "Kaloleni", "Jericho", "Donholm", "Umoja", "Buruburu"]),

    # ========== MOMBASA ROUTES (4) ==========
    # Mombasa Town to Nyali via Nyali Bridge
    ("Mombasa Town", "Nyali", ["Kizingo", "Nyali Bridge", "Nyali Cinemax", "City Mall"]),

    # Mombasa Town to Likoni via Ferry
    ("Mombasa Town", "Likoni", ["Likoni Ferry", "Shelly Beach", "Tiwi Junction"]),

    # Mombasa Town to Bamburi via Mombasa Road
    ("Mombasa Town", "Bamburi", ["Mwembe Tayari", "Nyali", "Kongowea", "Bamburi Mtambo"]),

    # Nyali to Bamburi coastal route
    ("Nyali", "Bamburi", ["Nyali Bridge", "Reef Hotel", "Mamba Village", "Bombolulu"]),

    # ========== NAKURU ROUTES (3) ==========
    # Nakuru Town to Free Area
    ("Nakuru Town", "Free Area", ["Kenyatta Avenue", "Stadium", "Pangani", "Kivumbini"]),

    # Nakuru Town to Lanet
    ("Nakuru Town", "Lanet", ["Kenyatta Avenue", "London", "Milimani", "Lanet Barracks"]),

    # Nakuru Town to Section 58
    ("Nakuru Town", "Section 58", ["Kenyatta Avenue", "Flamingo", "Mwariki", "Section 7"]),

    # ========== ELDORET ROUTES (3) ==========
    # Eldoret Town to Langas
    ("Eldoret Town", "Langas", ["Rupa's Mall", "Kapsoya", "Huruma", "Langas Estate"]),

    # Eldoret Town to Pioneer
    ("Eldoret Town", "Pioneer", ["Uganda Road", "Kipkaren", "West Indies", "Pioneer Estate"]),

    # Eldoret Town to Elgon View
    ("Eldoret Town", "Elgon View", ["Oginga Odinga Street", "Race Course", "Kapseret", "Elgon View Estate"]),

    # ========== KISUMU ROUTES (4) ==========
    # Kisumu Town to Kondele (Route 9)
    ("Kisumu Town", "Kondele", ["Kibuye Market", "Jubilee Market", "Kondele Roundabout"]),

    # Kisumu Town to Mamboleo (Route 10)
    ("Kisumu Town", "Mamboleo", ["Kibuye Market", "Kondele", "Nyamasaria", "Mamboleo Estate"]),

    # Kisumu Town to Manyatta (Route 9)
    ("Kisumu Town", "Manyatta", ["Kibuye Market", "Kondele", "Railway Station", "Manyatta Estate"]),

    # Kondele to Mamboleo connecting route
    ("Kondele", "Mamboleo", ["Kondele Roundabout", "Nyamasaria", "Migosi", "Mamboleo Junction"]),
]

def generate_routes_and_fares():
    """Generate realistic Kenyan matatu routes and fares"""
    routes, fares = [], []
    # Common matatu fare amounts in Kenya (usually 70, 80, or 100 Ksh)
    COMMON_FARES = [70, 80, 100]

    for idx, (origin, dest, stages) in enumerate(REAL_ROUTES):
        route_id = f"route_{idx + 1}"
        routes.append({
            "route_id": route_id,
            "origin": origin,
            "destination": dest,
            "stages": f"{origin},{','.join(stages)},{dest}",
            "is_verified": True
        })

        # Generate realistic fares based on route length
        num_stages = len(stages) + 2  # +2 for origin and destination

        # Shorter routes (4-5 stages) = 70 Ksh
        # Medium routes (6-7 stages) = 80 Ksh
        # Longer routes (8+ stages) = 100 Ksh
        if num_stages <= 5:
            standard_fare = 70
        elif num_stages <= 7:
            standard_fare = 80
        else:
            standard_fare = 100

        fares.append({
            "route_id": route_id,
            "standard_fare": standard_fare,
            "peak_multiplier": round(random.uniform(1.2, 1.5), 2),
            "peak_hours_starts": "07:00",
            "peak_hours_end": "09:00"
        })
    return routes, fares

if __name__ == "__main__":
    routes, fares = generate_routes_and_fares()

    # Save JSON
    import os
    os.makedirs('scripts/mock_data', exist_ok=True)

    with open('scripts/mock_data/routes.json', 'w') as f:
        json.dump(routes, f, indent=2)

    with open('scripts/mock_data/fares.json', 'w') as f:
        json.dump(fares, f, indent=2)

    print(f"✅ Generated {len(routes)} routes and {len(fares)} fares")
    print("📁 Saved to scripts/mock_data/")
    print("\n📊 Routes by City:")
    print("   - Nairobi: 5 routes")
    print("   - Mombasa: 4 routes")
    print("   - Nakuru: 3 routes")
    print("   - Eldoret: 3 routes")
    print("   - Kisumu: 4 routes")
    print("\nSample Nairobi route:")
    print(json.dumps(routes[0], indent=2))
    print("\nSample Mombasa route:")
    print(json.dumps(routes[5], indent=2))
    print("\nSample fare:")
    print(json.dumps(fares[0], indent=2))
