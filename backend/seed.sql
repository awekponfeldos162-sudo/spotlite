-- ============================================
-- SPOTLITE - Données de test
-- ============================================

-- Profils de test (les UUIDs doivent correspondre à des users Supabase Auth)
INSERT INTO profiles (id, email, type_utilisateur) VALUES
  ('00000000-0000-0000-0000-000000000001', 'talent1@spotlite.com', 'talent'),
  ('00000000-0000-0000-0000-000000000002', 'talent2@spotlite.com', 'talent'),
  ('00000000-0000-0000-0000-000000000003', 'employer1@spotlite.com', 'employeur');

-- Talents
INSERT INTO talents (id, profile_id, nom, titre, biographie, secteur, statut_recherche, score_qualification) VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Aya Koné', 'Développeuse Flutter Senior', 'Passionnée par les apps mobiles cross-platform.', 'Tech', 'disponible', 85),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002',
   'Marc Dupont', 'Designer UI/UX', 'Spécialiste en design de produits numériques innovants.', 'Créatif', 'disponible', 72);

-- Skills
INSERT INTO skills (talent_id, nom, niveau, is_verified) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Flutter', 'expert', true),
  ('10000000-0000-0000-0000-000000000001', 'Dart', 'expert', true),
  ('10000000-0000-0000-0000-000000000001', 'Supabase', 'avancé', false),
  ('10000000-0000-0000-0000-000000000002', 'Figma', 'expert', true),
  ('10000000-0000-0000-0000-000000000002', 'React', 'intermédiaire', false);

-- Employer
INSERT INTO employers (id, profile_id, nom_entreprise, secteur, taille, localisation) VALUES
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003',
   'TechCorp Africa', 'Tech', 'startup', 'Abidjan');

-- Stage (portfolio)
INSERT INTO spotlite_stages (talent_id, titre, blocs) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Mon Portfolio Flutter', '[
    {"id":"bloc_1","type":"texte","position":{"x":0,"y":0},"taille":{"w":400,"h":100},"contenu":{"texte":"Développeuse Flutter passionnée"}},
    {"id":"bloc_2","type":"skill_badge","position":{"x":0,"y":120},"taille":{"w":150,"h":50},"contenu":{"skill":"Flutter","verified":true}},
    {"id":"bloc_3","type":"lien","position":{"x":200,"y":120},"taille":{"w":150,"h":50},"contenu":{"url":"https://github.com/aya","label":"GitHub"}}
  ]');