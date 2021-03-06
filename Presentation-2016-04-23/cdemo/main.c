#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <gtk/gtk.h>

int lua_gtk_dialog( lua_State *L );

int main( int argc, char **argv) {
  char buff[256];
  int error;
  lua_State *L = luaL_newstate();
  lua_pushcfunction(L, lua_gtk_dialog);
  lua_setglobal(L, "dialog");
  luaL_openlibs(L);
  gtk_init(&argc, &argv);

  while( fgets(buff, sizeof(buff), stdin) != NULL) {
    error = luaL_loadbuffer(L, buff, strlen(buff), "line") ||
      lua_pcall(L, 0, 0, 0);
    if (error) {
      fprintf(stderr, "%s", lua_tostring(L, -1));
      lua_pop(L, 1); /* pop error message from the stack */
    }
  }
  printf("Interrupt signal.");
  lua_close(L);
  return 0;
}

int lua_gtk_dialog( lua_State *L ) {
  const char *message1 = luaL_checkstring(L, 1);
  const char *message2 = luaL_checkstring(L, 2);
  GtkWidget *dial = gtk_message_dialog_new( NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_INFO, GTK_BUTTONS_OK, message1);
  gtk_message_dialog_format_secondary_text(GTK_MESSAGE_DIALOG(dial),message2);
  gtk_dialog_run(GTK_DIALOG( dial ));
  return 0;
}
