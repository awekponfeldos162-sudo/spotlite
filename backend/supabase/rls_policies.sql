-- ============================================
-- SPOTLITE - Row Level Security (RLS)
-- ============================================

ALTER TABLE profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE talents          ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills           ENABLE ROW LEVEL SECURITY;
ALTER TABLE spotlite_stages  ENABLE ROW LEVEL SECURITY;
ALTER TABLE employers        ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches          ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications    ENABLE ROW LEVEL SECURITY;

-- ── PROFILES ─────────────────────────────
CREATE POLICY "Lecture profil public"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Modifier son propre profil"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- ── TALENTS ──────────────────────────────
CREATE POLICY "Talents publics visibles"
  ON talents FOR SELECT USING (true);

CREATE POLICY "Talent modifie son profil"
  ON talents FOR ALL USING (
    profile_id = auth.uid()
  );

-- ── SKILLS ───────────────────────────────
CREATE POLICY "Skills publiques"
  ON skills FOR SELECT USING (true);

CREATE POLICY "Talent gère ses skills"
  ON skills FOR ALL USING (
    talent_id IN (
      SELECT id FROM talents WHERE profile_id = auth.uid()
    )
  );

-- ── STAGES ───────────────────────────────
CREATE POLICY "Stages publics visibles"
  ON spotlite_stages FOR SELECT USING (is_public = true);

CREATE POLICY "Talent gère son stage"
  ON spotlite_stages FOR ALL USING (
    talent_id IN (
      SELECT id FROM talents WHERE profile_id = auth.uid()
    )
  );

-- ── EMPLOYERS ────────────────────────────
CREATE POLICY "Employeurs visibles"
  ON employers FOR SELECT USING (true);

CREATE POLICY "Employeur modifie son profil"
  ON employers FOR ALL USING (
    profile_id = auth.uid()
  );

-- ── MATCHES ──────────────────────────────
CREATE POLICY "Voir ses propres matches"
  ON matches FOR SELECT USING (
    talent_id IN (SELECT id FROM talents WHERE profile_id = auth.uid())
    OR
    employer_id IN (SELECT id FROM employers WHERE profile_id = auth.uid())
  );

CREATE POLICY "Créer un match"
  ON matches FOR INSERT WITH CHECK (
    talent_id IN (SELECT id FROM talents WHERE profile_id = auth.uid())
    OR
    employer_id IN (SELECT id FROM employers WHERE profile_id = auth.uid())
  );

CREATE POLICY "Mettre à jour un match"
  ON matches FOR UPDATE USING (
    talent_id IN (SELECT id FROM talents WHERE profile_id = auth.uid())
    OR
    employer_id IN (SELECT id FROM employers WHERE profile_id = auth.uid())
  );

-- ── NOTIFICATIONS ─────────────────────────
CREATE POLICY "Voir ses notifications"
  ON notifications FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Marquer comme lue"
  ON notifications FOR UPDATE USING (user_id = auth.uid());

  //les nouveaux shemas pour les notifications et les stages sont ajoutés, ainsi que les triggers pour mettre à jour automatiquement le champ updated_at lors de chaque modification.

  -- RLS nouvelles tables uniquement
ALTER TABLE posts                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments              ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges            ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "posts_select_public"
  ON posts FOR SELECT USING (true);
CREATE POLICY "posts_insert_own"
  ON posts FOR INSERT WITH CHECK (profile_id = auth.uid());
CREATE POLICY "posts_update_own"
  ON posts FOR UPDATE USING (profile_id = auth.uid());
CREATE POLICY "posts_delete_own"
  ON posts FOR DELETE USING (profile_id = auth.uid());

CREATE POLICY "likes_select_public"
  ON likes FOR SELECT USING (true);
CREATE POLICY "likes_insert_own"
  ON likes FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "likes_delete_own"
  ON likes FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "comments_select_public"
  ON comments FOR SELECT USING (true);
CREATE POLICY "comments_insert_own"
  ON comments FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "comments_delete_own"
  ON comments FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "challenges_select_public"
  ON challenges FOR SELECT USING (true);
CREATE POLICY "challenges_manage_own"
  ON challenges FOR ALL USING (
    employer_id IN (SELECT id FROM employers WHERE profile_id = auth.uid())
  );

CREATE POLICY "submissions_select_own"
  ON challenge_submissions FOR SELECT USING (
    talent_id IN (SELECT id FROM talents WHERE profile_id = auth.uid())
    OR
    challenge_id IN (
      SELECT id FROM challenges WHERE employer_id IN (
        SELECT id FROM employers WHERE profile_id = auth.uid()
      )
    )
  );
CREATE POLICY "submissions_insert_own"
  ON challenge_submissions FOR INSERT WITH CHECK (
    talent_id IN (SELECT id FROM talents WHERE profile_id = auth.uid())
  );