import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Users as UsersIcon, Shield, UserCog } from "lucide-react";
import { useUserRole } from "@/hooks/useUserRole";
import { useNavigate } from "react-router-dom";

type User = {
  id: string;
  email: string;
  created_at: string;
};

type UserWithRole = User & {
  role: "director" | "admin" | null;
};

const Users = () => {
  const [users, setUsers] = useState<UserWithRole[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();
  const { isDirector } = useUserRole();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isDirector) {
      navigate("/dashboard");
      return;
    }
    fetchUsers();
  }, [isDirector, navigate]);

  const fetchUsers = async () => {
    setLoading(true);
    
    // Fetch all auth users
    const { data: { users: authUsers }, error: authError } = await supabase.auth.admin.listUsers();
    
    if (authError) {
      toast({
        title: "Erro ao carregar utilizadores",
        description: authError.message,
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    // Fetch user roles
    const { data: roles } = await supabase
      .from("user_roles")
      .select("user_id, role");

    const usersWithRoles: UserWithRole[] = (authUsers || []).map(user => {
      const userRole = roles?.find(r => r.user_id === user.id);
      return {
        id: user.id,
        email: user.email || "Sem email",
        created_at: user.created_at,
        role: userRole?.role as "director" | "admin" | null,
      };
    });

    setUsers(usersWithRoles);
    setLoading(false);
  };

  const handleRoleChange = async (userId: string, newRole: "director" | "admin" | "none") => {
    if (newRole === "none") {
      const { error } = await supabase
        .from("user_roles")
        .delete()
        .eq("user_id", userId);

      if (error) {
        toast({
          title: "Erro ao remover função",
          description: error.message,
          variant: "destructive",
        });
        return;
      }
    } else {
      const { error } = await supabase
        .from("user_roles")
        .upsert({ user_id: userId, role: newRole });

      if (error) {
        toast({
          title: "Erro ao atualizar função",
          description: error.message,
          variant: "destructive",
        });
        return;
      }
    }

    toast({
      title: "Função atualizada",
      description: "A função do utilizador foi atualizada com sucesso.",
    });

    fetchUsers();
  };

  const getRoleBadge = (role: "director" | "admin" | null) => {
    if (role === "director") {
      return <Badge className="gap-1"><Shield className="w-3 h-3" /> Diretor</Badge>;
    }
    if (role === "admin") {
      return <Badge variant="secondary" className="gap-1"><UserCog className="w-3 h-3" /> Admin</Badge>;
    }
    return <Badge variant="outline">Sem função</Badge>;
  };

  if (!isDirector) {
    return null;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <UsersIcon className="h-8 w-8" />
          Gestão de Utilizadores
        </h1>
        <p className="text-muted-foreground mt-2">
          Atribua funções aos utilizadores do sistema
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Utilizadores do Sistema</CardTitle>
          <CardDescription>
            Apenas diretores têm acesso a finanças e IA. Admins têm acesso a alunos, funcionários e departamentos.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-center py-8">A carregar utilizadores...</p>
          ) : (
            <div className="space-y-4">
              {users.map((user) => (
                <div
                  key={user.id}
                  className="flex items-center justify-between p-4 border rounded-lg"
                >
                  <div className="space-y-1">
                    <p className="font-medium">{user.email}</p>
                    <p className="text-sm text-muted-foreground">
                      Criado em {new Date(user.created_at).toLocaleDateString("pt-PT")}
                    </p>
                  </div>
                  <div className="flex items-center gap-4">
                    {getRoleBadge(user.role)}
                    <Select
                      value={user.role || "none"}
                      onValueChange={(value) => handleRoleChange(user.id, value as any)}
                    >
                      <SelectTrigger className="w-[180px]">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">Sem função</SelectItem>
                        <SelectItem value="admin">Admin</SelectItem>
                        <SelectItem value="director">Diretor</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default Users;
