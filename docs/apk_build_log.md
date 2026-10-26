# Registro de compilación APK

## 2026-10-26 — Preparación del proyecto y CI
- Añadidos datos ampliados: siete facciones, nueve zonas, doce nodos narrativos, veinte misiones, diez encuentros yōkai, crafteo y sistemas de clima/combate/finales.
- Añadido `.github/workflows/build-apk.yml` para exportar Android en GitHub Actions, subir el APK como artefacto y copiarlo al repositorio en `main`.
- Añadido preset Android y clave de depuración efímera generada por CI.
- Añadidos cinco auditores deterministas bajo `tools/agents/` y ampliado `tools/validate_json.py`.
- **Pendiente de verificación externa:** no se afirma que el workflow haya terminado correctamente ni que exista un APK instalable hasta inspeccionar una ejecución de Actions y probar el archivo en Android.
- La implementación jugable sigue siendo prototipo; los sistemas ampliados están parcialmente representados como datos y aún requieren código de juego, arte y pruebas.
