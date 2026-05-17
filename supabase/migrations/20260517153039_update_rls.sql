-- Allow logged-in users to insert new venues
CREATE POLICY "Enable insert for authenticated users" 
ON public.venues 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- (Optional but recommended) Allow everyone to READ venues so the map loads!
CREATE POLICY "Enable read access for all users" 
ON public.venues 
FOR SELECT 
USING (true);