// ============================================
// SPOTLITE - Edge Function : Notifications
// Déployer : supabase functions deploy notification_trigger
// ============================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const payload = await req.json();
  const { type, match_id } = payload;

  // Récupérer le match complet
  const { data: match } = await supabase
    .from("matches")
    .select(`
      *,
      talents(profile_id, nom),
      employers(profile_id, nom_entreprise)
    `)
    .eq("id", match_id)
    .single();

  if (!match) return new Response("Match introuvable", { status: 404 });

  const notifications = [];

  if (type === "employer_like") {
    // Notifier le talent qu'un employeur l'a flashé
    notifications.push({
      user_id: match.talents.profile_id,
      type: "profil_vu",
      titre: "⚡ Quelqu'un a flashé sur votre profil !",
      corps: `${match.employers.nom_entreprise} s'intéresse à votre profil.`,
      data: { match_id, employer_id: match.employer_id },
    });
  }

  if (type === "match_confirmed") {
    // Notifier les deux parties d'un match confirmé
    notifications.push(
      {
        user_id: match.talents.profile_id,
        type: "match_accepte",
        titre: "🎉 C'est un Match !",
        corps: `Vous avez matché avec ${match.employers.nom_entreprise} !`,
        data: { match_id },
      },
      {
        user_id: match.employers.profile_id,
        type: "match_accepte",
        titre: "🎉 C'est un Match !",
        corps: `${match.talents.nom} a accepté votre invitation !`,
        data: { match_id },
      }
    );
  }

  if (notifications.length > 0) {
    await supabase.from("notifications").insert(notifications);
  }

  return new Response(JSON.stringify({ success: true, sent: notifications.length }), {
    headers: { "Content-Type": "application/json" },
  });
});