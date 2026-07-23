(lang dune 3.20)

(name tahanea)

(version dev)

(generate_opam_files)

(source
 (github lathan-l/tahanea-blog))

(license MIT)

(authors "lorie")

(maintainers "lorie")

(package
 (name tahanea)
 (synopsis "My first blog using YOCaml")
 (description "My first personal blog using YOCaml for fun and profit")
 (depends
  (ocaml
   (>= 5.3.0))
  hilite
  cmarkit
  ;; YOCaml
  yocaml
  yocaml_unix
  yocaml_yaml
  yocaml_markdown
  yocaml_jingoo ;; template engine
                ;; Dev setup
  (utop :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocp-indent :with-dev-setup)
  (merlin :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))
