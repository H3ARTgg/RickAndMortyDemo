struct CharacterCellsModel: Hashable {
    let id: Int
    let species: String
    let type: String
    let gender: String
    let originName: String
    let originType: String
    let episodes: [EpisodeModel]
}
