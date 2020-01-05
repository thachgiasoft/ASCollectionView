// ASCollectionView. Created by Apptek Studios 2019

import ASCollectionView
import SwiftUI
import UIKit

struct InstaFeedScreen: View
{
	@State var storiesData: [Post] = DataSource.postsForInstaSection(0, number: 12)
	@State var data: [[Post]] = (0 ... 1).map { DataSource.postsForInstaSection($0 + 1) }

	var storiesCollectionView: some View
	{
		ASCollectionView(
			section:
			ASSection(id: 0) {
				ASSectionDataSource(data: storiesData)
				{ item, _ in
					StoryView(post: item)
				}
				.onCellEvent(onCellEventStories)
		})
			.layout(scrollDirection: .horizontal)
		{
			.list(itemSize: .absolute(100), sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
		}
		.frame(height: 100)
		.scrollIndicatorsEnabled(false)
		.onCollectionViewReachedBoundary
		{ boundary in
			print("Reached the \(boundary) boundary")
		}
	}

	var storiesSection: ASSection<Int>
	{
		ASSection(id: 0)
		{
			storiesCollectionView
		}
	}

	var postSections: [ASSection<Int>]
	{
		data.enumerated().map
		{ i, sectionData in
			ASSection(id: i + 1) {
				ASSectionDataSource(data: sectionData)
				{ item, _ in
					PostView(post: item)
				}
				.onCellEvent(onCellEventPosts)
			}
			.tableViewSetEstimatedSizes(rowHeight: 500, headerHeight: 50) // Optional: Provide reasonable estimated heights for this section
			.sectionHeader
			{
				VStack(spacing: 0)
				{
					HStack
					{
						Text("Demo sticky header view")
							.padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
						Spacer()
					}
					Divider()
				}
				.background(Color(.secondarySystemBackground))
			}
		}
	}

	var sections: [ASSection<Int>]
	{
		[storiesSection] + postSections
	}

	var body: some View
	{
		ASTableView(sections: sections)
			.tableViewSeparatorsEnabled(false)
			.onTableViewPullToRefresh { endRefreshing in
				print("PULL TO REFRESH")
				Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
					endRefreshing()
				}
			}
			.onTableViewReachedBottom
		{
			self.loadMoreContent() // REACHED BOTTOM, LOADING MORE CONTENT
		}
		.navigationBarTitle("Insta Feed (tableview)", displayMode: .inline)
	}

	func loadMoreContent()
	{
		let a = data.count
		data.append(DataSource.postsForInstaSection(a + 1))
	}

	func onCellEventStories(_ event: CellEvent<Post>)
	{
		switch event
		{
		case let .onAppear(item):
			ASRemoteImageManager.shared.load(item.url)
		case let .onDisappear(item):
			ASRemoteImageManager.shared.cancelLoad(for: item.url)
		case let .prefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.load(item.url)
			}
		case let .cancelPrefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.cancelLoad(for: item.url)
			}
		}
	}

	func onCellEventPosts(_ event: CellEvent<Post>)
	{
		switch event
		{
		case let .onAppear(item):
			ASRemoteImageManager.shared.load(item.url)
			ASRemoteImageManager.shared.load(item.usernamePhotoURL)
		case let .onDisappear(item):
			ASRemoteImageManager.shared.cancelLoad(for: item.url)
			ASRemoteImageManager.shared.cancelLoad(for: item.usernamePhotoURL)
		case let .prefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.load(item.url)
				ASRemoteImageManager.shared.load(item.usernamePhotoURL)
			}
		case let .cancelPrefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.cancelLoad(for: item.url)
				ASRemoteImageManager.shared.cancelLoad(for: item.usernamePhotoURL)
			}
		}
	}
}

struct FeedView_Previews: PreviewProvider
{
	static var previews: some View
	{
		InstaFeedScreen()
	}
}
