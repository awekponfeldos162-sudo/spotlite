-- ============================================
-- SPOTLITE - Schéma PostgreSQL / Supabase
-- ============================================

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────
-- TABLE : profiles (utilisateurs communs)
-- ─────────────────────────────────────────
CREATE TABLE profiles (
  id               UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email            TEXT NOT NULL UNIQUE,
  type_utilisateur TEXT NOT NULL CHECK (type_utilisateur IN ('talent', 'employeur')),
  avatar_url       TEXT,
  date_creation    TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TABLE : talents
-- ─────────────────────────────────────────
CREATE TABLE talents (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  nom               TEXT NOT NULL,
  titre             TEXT,                          -- Ex: "Designer UX Senior"
  biographie        TEXT,
  secteur           TEXT,                          -- Ex: "Tech", "Créatif", "Finance"
  localisation      TEXT,
  statut_recherche  TEXT DEFAULT 'disponible'
                    CHECK (statut_recherche IN ('disponible', 'ouvert', 'passif', 'indisponible')),
  score_qualification INTEGER DEFAULT 0,           -- Score calculé par l'algo (0-100)
  salaire_min       INTEGER,
  salaire_max       INTEGER,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TABLE : skills
-- ─────────────────────────────────────────
CREATE TABLE skills (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  talent_id   UUID NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
  nom         TEXT NOT NULL,                       -- Ex: "Flutter", "Figma"
  niveau      TEXT CHECK (niveau IN ('débutant', 'intermédiaire', 'avancé', 'expert')),
  is_verified BOOLEAN DEFAULT FALSE,               -- Validé par test Spotlite
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TABLE : spotlite_stages (portfolio dynamique)
-- ─────────────────────────────────────────
CREATE TABLE spotlite_stages (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  talent_id  UUID NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
  titre      TEXT NOT NULL DEFAULT 'Mon Stage',
  blocs      JSONB NOT NULL DEFAULT '[]',
  -- Structure JSON d'un bloc :
  -- {
  --   "id": "bloc_1",
  --   "type": "image"|"texte"|"video"|"skill_badge"|"lien",
  --   "position": {"x": 0, "y": 0},
  --   "taille": {"w": 300, "h": 200},
  --   "contenu": { ... }
  -- }
  theme      TEXT DEFAULT 'dark',
  is_public  BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TABLE : employers
-- ─────────────────────────────────────────
CREATE TABLE employers (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  nom_entreprise   TEXT NOT NULL,
  secteur          TEXT,
  taille           TEXT CHECK (taille IN ('startup', 'pme', 'etl', 'grand_groupe')),
  description      TEXT,
  site_web         TEXT,
  logo_url         TEXT,
  localisation     TEXT,
  pays             TEXT,
  verified         BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TABLE : matches (mise en relation)
-- ─────────────────────────────────────────
CREATE TABLE matches (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  talent_id       UUID NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
  employer_id     UUID NOT NULL REFERENCES employers(id) ON DELETE CASCADE,
  initie_par      TEXT NOT NULL CHECK (initie_par IN ('talent', 'employeur')),
  talent_like     BOOLEAN DEFAULT FALSE,
  employer_like   BOOLEAN DEFAULT FALSE,
  statut          TEXT DEFAULT 'pending'
                  CHECK (statut IN ('pending', 'accepted', 'rejected')),
  message_initial TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(talent_id, employer_id)
);

-- ─────────────────────────────────────────
-- TABLE : notifications
-- ─────────────────────────────────────────
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type       TEXT NOT NULL,   -- 'nouveau_match', 'profil_vu', 'message', 'match_accepte'
  titre      TEXT NOT NULL,
  corps      TEXT,
  data       JSONB DEFAULT '{}',
  lue        BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- INDEXES pour les performances
-- ─────────────────────────────────────────
CREATE INDEX idx_talents_secteur          ON talents(secteur);
CREATE INDEX idx_talents_statut           ON talents(statut_recherche);
CREATE INDEX idx_talents_score            ON talents(score_qualification DESC);
CREATE INDEX idx_skills_talent_id         ON skills(talent_id);
CREATE INDEX idx_matches_talent_id        ON matches(talent_id);
CREATE INDEX idx_matches_employer_id      ON matches(employer_id);
CREATE INDEX idx_matches_statut           ON matches(statut);
CREATE INDEX idx_notifications_user_id    ON notifications(user_id);
CREATE INDEX idx_notifications_lue        ON notifications(lue);
CREATE INDEX idx_stages_talent_id         ON spotlite_stages(talent_id);

-- ─────────────────────────────────────────
-- TRIGGER : updated_at automatique
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_talents_updated_at
  BEFORE UPDATE ON talents FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_matches_updated_at
  BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_stages_updated_at
  BEFORE UPDATE ON spotlite_stages FOR EACH ROW EXECUTE FUNCTION update_updated_at();


  //les nouveveaux shemas pour les notifications et les stages sont ajoutés, ainsi que les triggers pour mettre à jour automatiquement le champ updated_at lors de chaque modification.
-- Seulement les nouvelles tables qui n'existent pas encore

CREATE TABLE IF NOT EXISTS posts (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  media_url   TEXT,
  media_type  TEXT CHECK (media_type IN ('image','video','none')) DEFAULT 'none',
  likes_count INTEGER DEFAULT 0,
  hashtags    TEXT[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE TABLE IF NOT EXISTS comments (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS challenges (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employer_id UUID NOT NULL REFERENCES employers(id) ON DELETE CASCADE,
  titre       TEXT NOT NULL,
  description TEXT,
  tags        JSONB DEFAULT '[]',
  points      INTEGER DEFAULT 10,
  deadline    TIMESTAMPTZ,
  is_premium  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS challenge_submissions (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  talent_id    UUID NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
  livrable_url TEXT NOT NULL,
  statut       TEXT DEFAULT 'pending'
               CHECK (statut IN ('pending','accepted','rejected')),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(challenge_id, talent_id)
);

-- Indexes nouveaux uniquement
CREATE INDEX IF NOT EXISTS idx_posts_profile_id   ON posts(profile_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at   ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_likes_post_id      ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id      ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_post_id   ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_challenges_premium ON challenges(is_premium);

-- Trigger posts uniquement (les autres existent déjà)
CREATE TRIGGER trg_posts_updated_at
  BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Fonction toggle_like
CREATE OR REPLACE FUNCTION toggle_like(p_post_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE already_liked BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM likes WHERE post_id = p_post_id AND user_id = p_user_id
  ) INTO already_liked;
  IF already_liked THEN
    DELETE FROM likes WHERE post_id = p_post_id AND user_id = p_user_id;
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = p_post_id;
    RETURN FALSE;
  ELSE
    INSERT INTO likes (post_id, user_id) VALUES (p_post_id, p_user_id);
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = p_post_id;
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;