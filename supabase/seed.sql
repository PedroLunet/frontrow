-- Insert Dummy Venues in Porto
-- Note: PostGIS geography uses Longitude first, then Latitude!
INSERT INTO public.venues (id, name, coordinates, mapbox_id, created_at)
VALUES
  -- Casa da Música (Approx: 41.1586° N, 8.6306° W)
  ('11111111-1111-1111-1111-111111111111', 'Casa da Música', 'POINT(-8.6306 41.1586)', 'mapbox_casa_musica_123', now()),
  -- Coliseu do Porto (Approx: 41.1469° N, 8.6056° W)
  ('22222222-2222-2222-2222-222222222222', 'Coliseu do Porto', 'POINT(-8.6056 41.1469)', 'mapbox_coliseu_456', now());

-- Insert Dummy Concerts
INSERT INTO public.concerts (id, artist, venue, date, description, name, image_url, created_at, updated_at)
VALUES
  ('33333333-3333-3333-3333-333333333333', 'Ornatos Violeta', '11111111-1111-1111-1111-111111111111', '2026-08-15 20:00:00+00', 'A legendary hometown rock show.', 'O Monstro Precisa de Amigos - Tour', 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800', now(), now()),
  ('44444444-4444-4444-4444-444444444444', 'Slow J', '22222222-2222-2222-2222-222222222222', '2026-09-10 19:30:00+00', 'Afro-Fado and hip hop fusion.', 'Afro Fado Ao Vivo', 'https://images.unsplash.com/photo-1540039155732-611114d6e350?w=800', now(), now());