{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  # model group marked as default, e.g. "DeepSeek-V4.1-Flash"
  defaultModel ? null,
}:
buildNpmPackage (finalAttrs: {
  pname = "vscode-extension-litellm-vscode";
  version = "0.1.0-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "BerriAI";
    repo = "litellm";
    rev = "6c0585b8f192efb2c07735468537a99824c7a94b";
    sparseCheckout = [ "vscode-extension" ];
    hash = "sha256-wXt4Fcq/z5etFuzedo+JbZzoQ1o/KV7oUwX5Q34xYEA=";
  };
  sourceRoot = "${finalAttrs.src.name}/vscode-extension";
  npmDepsHash = "sha256-RMLirOzdtefKrECZ/fSC66PMzi7elz1OSjYXyaNAMo8=";
  nativeBuildInputs = [ jq ];
  # Without a Copilot login the model picker cannot unhide models and no
  # Copilot model is the default, so chat waits for a model forever. Mark the
  # models selectable and one as default; isDefault needs the chatProvider
  # proposal, which argv.json must allow via enable-proposed-api.
  postPatch = ''
    substituteInPlace src/provider.ts --replace-fail \
      '  capabilities: { imageInput: descriptor.imageInput, toolCalling: descriptor.toolCalling },' \
      '  capabilities: { imageInput: descriptor.imageInput, toolCalling: descriptor.toolCalling },
      isUserSelectable: true,
      isDefault: descriptor.id === ${builtins.toJSON defaultModel},'
  '';
  # esbuild bundles openai into dist/extension.js, so node_modules is not needed at runtime.
  # apiKey loses its secret flag so VS Code takes it as plain text from
  # chatLanguageModels.json; the secret storage UI needs a Copilot login.
  installPhase = ''
    runHook preInstall
    dir=$out/share/vscode/extensions/litellm.litellm-vscode
    mkdir -p $dir
    cp -r README.md LICENSE dist $dir/
    jq 'del(.contributes.languageModelChatProviders[].configuration.properties.apiKey.secret)
      | .enabledApiProposals = ["chatProvider"]' \
      package.json > $dir/package.json
    runHook postInstall
  '';
  passthru = {
    vscodeExtPublisher = "litellm";
    vscodeExtName = "litellm-vscode";
    vscodeExtUniqueId = "litellm.litellm-vscode";
  };
})
