# Dependency Policy - C++

Use the approved Conan, vcpkg or vendoring process with lockfiles or immutable revisions.
Review licence, provenance, maintenance, CVEs, compiler/ABI compatibility and transitive native libraries.
Pin build options that affect ABI. Do not add header-only dependencies without the same review applied to binaries.
Generate a software bill of materials for released artifacts where required.
