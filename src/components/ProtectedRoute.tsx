import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useUserRole } from "@/hooks/useUserRole";
import { useToast } from "@/hooks/use-toast";

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireAdmin?: boolean;
}

export const ProtectedRoute = ({ children, requireAdmin = false }: ProtectedRouteProps) => {
  const { role, loading, isAdmin } = useUserRole();
  const navigate = useNavigate();
  const { toast } = useToast();

  useEffect(() => {
    if (!loading) {
      if (!role) {
        toast({
          title: "Acesso negado",
          description: "Você precisa fazer login para acessar esta página.",
          variant: "destructive",
        });
        navigate("/auth", { replace: true });
      } else if (requireAdmin && !isAdmin) {
        toast({
          title: "Acesso negado",
          description: "Você não tem permissão para acessar esta página.",
          variant: "destructive",
        });
        navigate("/dashboard", { replace: true });
      }
    }
  }, [role, loading, isAdmin, requireAdmin, navigate, toast]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!role || (requireAdmin && !isAdmin)) {
    return null;
  }

  return <>{children}</>;
};
