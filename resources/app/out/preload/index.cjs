"use strict";

// src/preload/index.ts
var import_electron = require("electron");
import_electron.contextBridge.exposeInMainWorld("app", {
  getPresenceUrl: () => import_electron.ipcRenderer.invoke("app:get-presence-url"),
  setPresenceUrl: (url) => import_electron.ipcRenderer.invoke("app:set-presence-url", url),
  getNsaid: () => import_electron.ipcRenderer.invoke("app:get-nsaid"),
  setNsaid: (nsaid) => import_electron.ipcRenderer.invoke("app:set-nsaid", nsaid),
  start: () => import_electron.ipcRenderer.invoke("app:start"),
  disconnect: () => import_electron.ipcRenderer.invoke("app:disconnect"),
  diagnose: (payload) => import_electron.ipcRenderer.invoke("app:diagnose", payload)
});
import_electron.contextBridge.exposeInMainWorld("presence", {
  getCurrent: () => import_electron.ipcRenderer.invoke("presence:current"),
  subscribe: (cb) => {
    import_electron.ipcRenderer.send("presence:subscribe");
    const handler = (_event, game) => cb(game);
    import_electron.ipcRenderer.on("presence:update", handler);
    return () => import_electron.ipcRenderer.removeListener("presence:update", handler);
  }
});
import_electron.contextBridge.exposeInMainWorld("discord", {
  getStatus: () => import_electron.ipcRenderer.invoke("discord:status"),
  toggle: () => import_electron.ipcRenderer.invoke("discord:toggle"),
  setClientId: (clientId) => import_electron.ipcRenderer.invoke("discord:set-client-id", clientId),
  getClientId: () => import_electron.ipcRenderer.invoke("discord:get-client-id")
});
import_electron.contextBridge.exposeInMainWorld("electron", {
  setAutoStart: (enabled) => import_electron.ipcRenderer.invoke("electron:set-auto-start", enabled),
  getAutoStart: () => import_electron.ipcRenderer.invoke("electron:get-auto-start"),
  minimize: () => import_electron.ipcRenderer.invoke("window:minimize"),
  close: () => import_electron.ipcRenderer.invoke("window:close"),
  openExternal: (url) => import_electron.ipcRenderer.invoke("open-external", url)
});
import_electron.contextBridge.exposeInMainWorld("gameHistory", {
  list: () => import_electron.ipcRenderer.invoke("history:list"),
  clear: () => import_electron.ipcRenderer.invoke("history:clear"),
  export: () => import_electron.ipcRenderer.invoke("history:export")
});
import_electron.contextBridge.exposeInMainWorld("totals", {
  list: () => import_electron.ipcRenderer.invoke("totals:list"),
  get: (name) => import_electron.ipcRenderer.invoke("totals:get", name),
  snapshots: (name) => import_electron.ipcRenderer.invoke("totals:snapshots", name),
  reset: () => import_electron.ipcRenderer.invoke("totals:reset")
});
import_electron.contextBridge.exposeInMainWorld("privacy", {
  get: () => import_electron.ipcRenderer.invoke("privacy:get"),
  setPrivateMode: (enabled) => import_electron.ipcRenderer.invoke("privacy:set-private-mode", enabled),
  setNotify: (enabled) => import_electron.ipcRenderer.invoke("privacy:set-notify", enabled),
  addHidden: (name) => import_electron.ipcRenderer.invoke("privacy:add-hidden", name),
  removeHidden: (name) => import_electron.ipcRenderer.invoke("privacy:remove-hidden", name)
});
