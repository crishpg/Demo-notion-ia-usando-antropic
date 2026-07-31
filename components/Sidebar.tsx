'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Users, 
  FolderKanban, 
  CheckSquare,
  ChevronRight,
  BarChart3,
  Computer
} from 'lucide-react';

const menuItems = [
  {
    title: 'Dashboard',
    href: '/',
    icon: LayoutDashboard,
  },
  {
    title: 'Clientes',
    href: '/clientes',
    icon: Users,
  },
  {
    title: 'Projetos',
    href: '/projetos',
    icon: FolderKanban,
  },
  {
    title: 'Atividades',
    href: '/atividades',
    icon: CheckSquare,
  },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-notion-100 dark:bg-notion-900 border-r border-notion-200 dark:border-notion-800 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-notion-200 dark:border-notion-800">
        <Link href="/" className="flex items-center gap-2 group">
          <div className="flex items-center justify-center w-8 h-8 rounded-md bg-accent-red text-white">
            <Computer className="w-5 h-5" />
          </div>
          <div>
            <h1 className="font-semibold text-notion-900 dark:text-notion-50 text-base">
              Sistema Freelancers
            </h1>
            <p className="text-xs text-notion-600 dark:text-notion-400">
              Gestão de Projetos
            </p>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
        <div className="mb-4">
          <div className="flex items-center gap-2 px-2 py-1.5 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wider">
            Menu
          </div>
          
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || 
                           (item.href !== '/' && pathname.startsWith(item.href));
            
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`
                  flex items-center gap-2 px-2 py-1.5 rounded-md text-sm font-medium
                  transition-colors duration-150
                  ${isActive 
                    ? 'bg-notion-200 dark:bg-notion-800 text-notion-900 dark:text-notion-50' 
                    : 'text-notion-700 dark:text-notion-300 hover:bg-notion-200/50 dark:hover:bg-notion-800/50'
                  }
                `}
              >
                <Icon className="w-4 h-4 flex-shrink-0" />
                <span className="flex-1">{item.title}</span>
                {isActive && (
                  <ChevronRight className="w-3 h-3 opacity-50" />
                )}
              </Link>
            );
          })}
        </div>

        {/* Seção Adicional */}
        <div className="pt-4 border-t border-notion-200 dark:border-notion-800">
          <div className="flex items-center gap-2 px-2 py-1.5 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wider">
            Estatísticas
          </div>
          
          <Link
            href="/estatisticas"
            className="flex items-center gap-2 px-2 py-1.5 rounded-md text-sm font-medium text-notion-700 dark:text-notion-300 hover:bg-notion-200/50 dark:hover:bg-notion-800/50"
          >
            <BarChart3 className="w-4 h-4 flex-shrink-0" />
            <span className="flex-1">Análises</span>
          </Link>
        </div>
      </nav>

      {/* Footer */}
      <div className="p-3 border-t border-notion-200 dark:border-notion-800">
        <div className="px-2 py-1.5 text-xs text-notion-600 dark:text-notion-400">
          <div className="flex items-center justify-between mb-1">
            <span className="font-medium">Versão</span>
            <span>1.0.0</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="font-medium">Ambiente</span>
            <span className="px-1.5 py-0.5 bg-accent-green/10 text-accent-green rounded text-[10px] font-semibold">
              DEV
            </span>
          </div>
        </div>
      </div>
    </aside>
  );
}
