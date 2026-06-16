// ============================================
// SPOTLITE - Edge Function : Matching Engine
// Déployer : supabase functions deploy matching_engine
// ============================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { employer_id, filtres } = await req.json();

  // 1. Récupérer les préférences de l'employeur
  const { data: employer } = await supabase
    .from("employers")
    .select("*")
    .eq("id", employer_id)
    .single();

  if (!employer) {
    return new Response(JSON.stringify({ error: "Employeur introuvable" }), { status: 404 });
  }

  // 2. Construire la requête de matching
  let query = supabase
    .from("talents")
    .select(`
      *,
      skills(*),
      spotlite_stages(id, titre, is_public),
      profiles(avatar_url, email)
    `)
    .eq("statut_recherche", "disponible")
    .order("score_qualification", { ascending: false })
    .limit(20);

  // Filtres dynamiques
  if (filtres?.secteur)       query = query.eq("secteur", filtres.secteur);
  if (filtres?.localisation)  query = query.eq("localisation", filtres.localisation);
  if (filtres?.salaire_max)   query = query.lte("salaire_min", filtres.salaire_max);

  const { data: talents, error } = await query;

  if (error) return new Response(JSON.stringify({ error }), { status: 500 });

  // 3. Exclure les talents déjà matchés avec cet employeur
  const { data: existingMatches } = await supabase
    .from("matches")
    .select("talent_id")
    .eq("employer_id", employer_id);

  const matchedIds = new Set(existingMatches?.map((m: any) => m.talent_id) ?? []);
  const filtered = talents?.filter((t: any) => !matchedIds.has(t.id)) ?? [];

  // 4. Score de compatibilité (algorithme simple extensible)
  const scored = filtered.map((talent: any) => {
    let score = talent.score_qualification;
    const skillsVerified = talent.skills?.filter((s: any) => s.is_verified).length ?? 0;
    score += skillsVerified * 5;
    if (talent.secteur === employer.secteur) score += 15;
    return { ...talent, compatibilite: Math.min(score, 100) };
  });

  scored.sort((a: any, b: any) => b.compatibilite - a.compatibilite);

  return new Response(JSON.stringify({ talents: scored }), {
    headers: { "Content-Type": "application/json" },
  });
});