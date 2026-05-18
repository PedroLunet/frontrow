-- Allow logged-in users to insert new concerts
CREATE POLICY "Enable insert for authenticated users" 
ON public.concerts 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- Allow everyone to READ concerts (so they actually show up on your map!)
CREATE POLICY "Enable read access for all users" 
ON public.concerts 
FOR SELECT 
USING (true);