import PBXProj

struct ElementCreator {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func create(
        pathTree: PathTreeNode,
        arguments: Arguments
    ) throws -> (
        partial: String,
        knownRegions: Set<String>,
        resolvedRepositories: [ResolvedRepository]
    ) {
        let executionRoot = try environment.readExecutionRootFile(
            arguments.executionRootFile
        )

        let createRootElements = environment.createCreateRootElements(
            executionRoot: executionRoot,
            externalDir: try environment.externalDir(
                executionRoot: executionRoot
            ),
            selectedModelVersions:
                try environment.readSelectedModelVersionsFile(
                    arguments.selectedModelVersionsFile
                ),
            workspace: arguments.workspace
        )
        let rootElements = createRootElements(for: pathTree)

        let mainGroup = environment.createMainGroupElement(
            childIdentifiers: rootElements.elements.map(\.identifier),
            workspace: arguments.workspace
        )

        let partial = environment.calculatePartial(
            elements: rootElements.transitiveElements,
            mainGroup: mainGroup,
            workspace: arguments.workspace
        )

        return (
            partial: partial,
            knownRegions: rootElements.knownRegions,
            resolvedRepositories: rootElements.resolvedRepositories
        )
    }
}
