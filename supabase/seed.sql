-- Insert Dummy Venues in Porto
-- Note: PostGIS geography uses Longitude first, then Latitude!
INSERT INTO public.venues (id, name, coordinates, mapbox_id, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Casa da Música', 'POINT(-8.6306 41.1586)', 'dXJuOm1ieHBvaTptYXBib3gtbjM4MDEyMw', now()),
  ('22222222-2222-2222-2222-222222222222', 'Ageas Coliseu do Porto', 'POINT(-8.605492 41.146818)', 'dXJuOm1ieHBvaTphMWQ0MjQxMy04Y2QzLTQyZjUtOGNlNC1jMmNlNjc0ZjgzYWY', now()),
  ('33333333-3333-3333-3333-333333333333', 'HardClub', 'POINT(-8.614953 41.141758)', 'dXJuOm1ieHBvaTozNDg0YTcxOS1kNGZkLTRjNmEtYTRjMC02MDZiZmQ4ZTE0Y2Q', now()),
  ('44444444-4444-4444-4444-444444444444', 'Maus Hábitos', 'POINT(-8.60572371 41.14673555)', 'dXJuOm1ieHBvaToxZmIwZmI0Mi00NjVmLTQ2N2ItYWIwMS02ZWQxNmY3ZDg4YWU', now()),
  ('55555555-5555-5555-5555-555555555555', 'Plano B', 'POINT(-8.613889 41.146428)', 'dXJuOm1ieHBvaTplMDI0OTkzNy1jM2I1LTRmNTgtYmYwMi1hYThjNzdmOWEyNTk', now());


-- Insert Dummy Concerts
INSERT INTO public.concerts (id, artist, venue, date, description, name, image_url, created_at, updated_at)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Ornatos Violeta', '11111111-1111-1111-1111-111111111111', '2026-08-15 20:00:00+00', 'A legendary hometown rock show.', 'O Monstro Precisa de Amigos - Tour', 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800', now(), now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Slow J', '22222222-2222-2222-2222-222222222222', '2026-09-10 19:30:00+00', 'Afro-Fado and hip hop fusion.', 'Afro Fado Ao Vivo', 'https://upload.wikimedia.org/wikipedia/pt/e/e8/Slow_J_-_Afro_Fado.jpeg', now(), now()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'TV Girl', '44444444-4444-4444-4444-444444444444', '2026-09-10 19:30:00+00', 'Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet', 'TV Girl Summer Tour', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJZJMDFH9tWJ6GpX1ekTBKbjIZRa9ZosQALg&s', now(), now()),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Men I Trust', '44444444-4444-4444-4444-444444444444', '2026-09-10 19:30:00+00', 'Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet', 'Men I Trust Equs Cabalus Tour', 'https://64.media.tumblr.com/0c314f607cff2114ae0354fd80405876/741087a14c63f83b-da/s500x750/d072327caa22ca8e74ec6ba725f93e3888fd52e8.png', now(), now()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Lagum', '33333333-3333-3333-3333-333333333333', '2026-09-10 19:30:00+00', 'Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Amet Ipsum lorem Sit Ame', 'Lagum Porto, As Curvas as Cores e as Dores do Mundo', 'https://agendaculturalporto.org/wp-content/uploads/2025/06/LAGUM-As-Cores-As-Curvas-e-as-Dores-do-Mundo.jpg', now(), now());