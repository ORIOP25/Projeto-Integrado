-- Create role enum
CREATE TYPE public.app_role AS ENUM ('director', 'admin');

-- Create user_roles table
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE (user_id, role)
);

-- Enable RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create security definer function to check roles
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

-- Create function to check if user is director
CREATE OR REPLACE FUNCTION public.is_director(_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = 'director'
  )
$$;

-- Create function to check if user has any admin role
CREATE OR REPLACE FUNCTION public.is_any_admin(_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role IN ('director', 'admin')
  )
$$;

-- RLS policies for user_roles table
CREATE POLICY "Directors can view all roles"
  ON public.user_roles FOR SELECT
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can insert roles"
  ON public.user_roles FOR INSERT
  WITH CHECK (public.is_director(auth.uid()));

CREATE POLICY "Directors can update roles"
  ON public.user_roles FOR UPDATE
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can delete roles"
  ON public.user_roles FOR DELETE
  USING (public.is_director(auth.uid()));

-- Update RLS policies for students table
DROP POLICY IF EXISTS "Allow authenticated users to read students" ON public.students;
DROP POLICY IF EXISTS "Allow authenticated users to insert students" ON public.students;
DROP POLICY IF EXISTS "Allow authenticated users to update students" ON public.students;
DROP POLICY IF EXISTS "Allow authenticated users to delete students" ON public.students;

CREATE POLICY "Admins can read students"
  ON public.students FOR SELECT
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can insert students"
  ON public.students FOR INSERT
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update students"
  ON public.students FOR UPDATE
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can delete students"
  ON public.students FOR DELETE
  USING (public.is_any_admin(auth.uid()));

-- Update RLS policies for staff table
DROP POLICY IF EXISTS "Allow authenticated users to read staff" ON public.staff;
DROP POLICY IF EXISTS "Allow authenticated users to insert staff" ON public.staff;
DROP POLICY IF EXISTS "Allow authenticated users to update staff" ON public.staff;
DROP POLICY IF EXISTS "Allow authenticated users to delete staff" ON public.staff;

CREATE POLICY "Admins can read staff"
  ON public.staff FOR SELECT
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can insert staff"
  ON public.staff FOR INSERT
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update staff"
  ON public.staff FOR UPDATE
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can delete staff"
  ON public.staff FOR DELETE
  USING (public.is_any_admin(auth.uid()));

-- Update RLS policies for departments table
DROP POLICY IF EXISTS "Allow authenticated users to read departments" ON public.departments;
DROP POLICY IF EXISTS "Allow authenticated users to insert departments" ON public.departments;
DROP POLICY IF EXISTS "Allow authenticated users to update departments" ON public.departments;

CREATE POLICY "Admins can read departments"
  ON public.departments FOR SELECT
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can insert departments"
  ON public.departments FOR INSERT
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update departments"
  ON public.departments FOR UPDATE
  USING (public.is_any_admin(auth.uid()));

-- Update RLS policies for financial_transactions table (DIRECTORS ONLY)
DROP POLICY IF EXISTS "Allow authenticated users to read transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Allow authenticated users to insert transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Allow authenticated users to update transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Allow authenticated users to delete transactions" ON public.financial_transactions;

CREATE POLICY "Directors can read transactions"
  ON public.financial_transactions FOR SELECT
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can insert transactions"
  ON public.financial_transactions FOR INSERT
  WITH CHECK (public.is_director(auth.uid()));

CREATE POLICY "Directors can update transactions"
  ON public.financial_transactions FOR UPDATE
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can delete transactions"
  ON public.financial_transactions FOR DELETE
  USING (public.is_director(auth.uid()));