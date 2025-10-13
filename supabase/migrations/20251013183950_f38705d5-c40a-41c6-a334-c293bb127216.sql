-- Fix RLS policies: Convert RESTRICTIVE to PERMISSIVE (default)
-- This ensures proper RLS policy evaluation order

-- Departments table
DROP POLICY IF EXISTS "Admins can insert departments" ON public.departments;
DROP POLICY IF EXISTS "Admins can read departments" ON public.departments;
DROP POLICY IF EXISTS "Admins can update departments" ON public.departments;

CREATE POLICY "Admins can insert departments" ON public.departments
  FOR INSERT TO authenticated
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can read departments" ON public.departments
  FOR SELECT TO authenticated
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update departments" ON public.departments
  FOR UPDATE TO authenticated
  USING (public.is_any_admin(auth.uid()));

-- Students table
DROP POLICY IF EXISTS "Admins can delete students" ON public.students;
DROP POLICY IF EXISTS "Admins can insert students" ON public.students;
DROP POLICY IF EXISTS "Admins can read students" ON public.students;
DROP POLICY IF EXISTS "Admins can update students" ON public.students;

CREATE POLICY "Admins can delete students" ON public.students
  FOR DELETE TO authenticated
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can insert students" ON public.students
  FOR INSERT TO authenticated
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can read students" ON public.students
  FOR SELECT TO authenticated
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update students" ON public.students
  FOR UPDATE TO authenticated
  USING (public.is_any_admin(auth.uid()));

-- Staff table
DROP POLICY IF EXISTS "Admins can delete staff" ON public.staff;
DROP POLICY IF EXISTS "Admins can insert staff" ON public.staff;
DROP POLICY IF EXISTS "Admins can read staff" ON public.staff;
DROP POLICY IF EXISTS "Admins can update staff" ON public.staff;

CREATE POLICY "Admins can delete staff" ON public.staff
  FOR DELETE TO authenticated
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can insert staff" ON public.staff
  FOR INSERT TO authenticated
  WITH CHECK (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can read staff" ON public.staff
  FOR SELECT TO authenticated
  USING (public.is_any_admin(auth.uid()));

CREATE POLICY "Admins can update staff" ON public.staff
  FOR UPDATE TO authenticated
  USING (public.is_any_admin(auth.uid()));

-- Financial transactions table
DROP POLICY IF EXISTS "Directors can delete transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Directors can insert transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Directors can read transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Directors can update transactions" ON public.financial_transactions;

CREATE POLICY "Directors can delete transactions" ON public.financial_transactions
  FOR DELETE TO authenticated
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can insert transactions" ON public.financial_transactions
  FOR INSERT TO authenticated
  WITH CHECK (public.is_director(auth.uid()));

CREATE POLICY "Directors can read transactions" ON public.financial_transactions
  FOR SELECT TO authenticated
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can update transactions" ON public.financial_transactions
  FOR UPDATE TO authenticated
  USING (public.is_director(auth.uid()));

-- User roles table
DROP POLICY IF EXISTS "Directors can delete roles" ON public.user_roles;
DROP POLICY IF EXISTS "Directors can insert roles" ON public.user_roles;
DROP POLICY IF EXISTS "Directors can update roles" ON public.user_roles;
DROP POLICY IF EXISTS "Directors can view all roles" ON public.user_roles;

CREATE POLICY "Directors can delete roles" ON public.user_roles
  FOR DELETE TO authenticated
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can insert roles" ON public.user_roles
  FOR INSERT TO authenticated
  WITH CHECK (public.is_director(auth.uid()));

CREATE POLICY "Directors can update roles" ON public.user_roles
  FOR UPDATE TO authenticated
  USING (public.is_director(auth.uid()));

CREATE POLICY "Directors can view all roles" ON public.user_roles
  FOR SELECT TO authenticated
  USING (public.is_director(auth.uid()));