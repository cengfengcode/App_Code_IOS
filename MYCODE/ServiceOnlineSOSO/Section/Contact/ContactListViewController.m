//
//  ContactListViewController.m
//  MyChat
//
//  Created by 沈家林 on 16/5/9.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "ContactListViewController.h"
#import "EaseChineseToPinyin.h"
#import "ChatViewController.h"
#import "LoginViewController.h"

@interface ContactListViewController ()<UIActionSheetDelegate,EaseUserCellDelegate,EMContactManagerDelegate>
{
    NSInteger _currentLongPressIndex;
}
@property (strong, nonatomic) NSMutableArray *sectionTitles;
@property (strong, nonatomic) NSMutableArray *contactsSource;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];

    //改变导航栏的颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29/255.0f green:186/255.0f blue:156/255.0f alpha:1];
    //添加好友按钮
    UIBarButtonItem * lbbItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonEvent)];
    self.navigationItem.rightBarButtonItem = lbbItem;

    //注销按钮
    UIBarButtonItem * rbbItem = [[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonEvent)];
    self.navigationItem.leftBarButtonItem = rbbItem;

    _contactsSource = [NSMutableArray array];
    _sectionTitles = [NSMutableArray array];
    [self loadData];
}

- (void)logoutButtonEvent {
    EMError *error = [[EMClient sharedClient] logout:YES];
    if (!error) {
        NSLog(@"退出成功");
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
//添加好友
- (void)backButtonEvent {
    NSLog(@"添加好友喽!");
    //弹出警示框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加好友" preferredStyle:UIAlertControllerStyleAlert];
    //设置两个输入框
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //block 中对输入框进行设置
        textField.placeholder = @"请输入好友用户名";
    }];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //block 中对输入框进行设置
        textField.placeholder = @"请输入验证信息";
    }];
    //取消按钮
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //确定按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取警示框上的输入框
        NSArray *tfArray = alertVC.textFields;
        UITextField *userNameTF = tfArray.firstObject;
        UITextField *infoTF = tfArray.lastObject;
        if (![self.dataArray containsObject:userNameTF.text]) {
            //发送好友请求
            EMError *error = [[EMClient sharedClient].contactManager addContact: userNameTF.text message:infoTF.text];
            if (!error) {
                NSLog(@"添加成功");
            }
        } else {
            NSLog(@"对方已经是您的好友");
        }
    }];
    [alertVC addAction:cancleAction];
    [alertVC addAction:confirmAction];
    //弹出警示框
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - EMChatManagerDelegate
/*!
 *  用户A发送加用户B为好友的申请，用户B会收到这个回调
 *
 *  @param aUsername   用户名
 *  @param aMessage    附属信息
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    //弹出警示框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"添加好友请求" message:[NSString stringWithFormat:@"%@请求添加您为好友", aUsername] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //拒绝添加好友
        EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:aUsername];
        if (!error) {
            NSLog(@"发送拒绝成功");
        }
    }];
    UIAlertAction *agree = [UIAlertAction actionWithTitle:@"同意" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //同意添加好友
        EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:aUsername];
        if (!error) {
            NSLog(@"发送同意成功");
            if ([self.dataArray containsObject:aUsername]) {
                return;
            }

            [self getAllFriends];
            [self.contactsSource addObject:aUsername];
            [self _sortDataArray:self.contactsSource];
        }
    }];
    //添加按钮
    [alertVC addAction:cancle];
    [alertVC addAction:agree];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    //插入单元格, 添加到数据源
    [self getAllFriends];
    [self.contactsSource addObject:aUsername];
    [self _sortDataArray:self.contactsSource];

}

//检索好友
- (void)getAllFriends {
    [self.contactsSource removeAllObjects];
    EMError *error = nil;
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (!error) {
        NSLog(@"获取成功 -- %@",userlist);
        //添加到数据源
        [self.contactsSource addObjectsFromArray:userlist];
        //刷新界面
        [self.tableView reloadData];
    }
}


-(void)loadData{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            [[EMClient sharedClient].contactManager getBlackListFromServerWithError:&error];
            if (!error) {
                [weakself.contactsSource removeAllObjects];
                
                for (NSInteger i = (buddyList.count - 1); i >= 0; i--) {
                    NSString *username = [buddyList objectAtIndex:i];
                    [weakself.contactsSource addObject:username];
                }
                
                NSString *loginUsername = [[EMClient sharedClient] currentUsername];
                if (loginUsername && loginUsername.length > 0) {
                    [weakself.contactsSource addObject:loginUsername];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself _sortDataArray:self.contactsSource];
                });
            }
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:YES];
    });

}


- (void)_sortDataArray:(NSArray *)buddyList
{
    [self.dataArray removeAllObjects];
    [self.sectionTitles removeAllObjects];
    NSMutableArray *contactsSource = [NSMutableArray array];
    
    //从获取的数据中剔除黑名单中的好友
    NSArray *blockList = [[EMClient sharedClient].contactManager getBlackListFromDB];
    for (NSString *buddy in buddyList) {
        if (![blockList containsObject:buddy]) {
            [contactsSource addObject:buddy];
        }
    }
    
    //建立索引的核心, 返回27，是a－z和＃
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    //分区个数
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //按首字母分组
    for (NSString *buddy in contactsSource) {
        EaseUserModel *model = [[EaseUserModel alloc] initWithBuddy:buddy];
        if (model) {
            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
            model.nickname = buddy;

            NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:buddy];
            NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
            
            NSMutableArray *array = [sortedArray objectAtIndex:section];
            [array addObject:model];
        }
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EaseUserModel *obj1, EaseUserModel *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1.buddy];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2.buddy];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    //去掉空的section
    for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
        NSArray *array = [sortedArray objectAtIndex:i];
        if ([array count] == 0) {
            [sortedArray removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    [self.dataArray addObjectsFromArray:sortedArray];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [EaseUserCell cellIdentifierWithModel:nil];
    EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray *userSection = [self.dataArray objectAtIndex:indexPath.section];
    EaseUserModel *model = [userSection objectAtIndex:indexPath.row];
//    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.buddy];
//    if (profileEntity) {
//        model.avatarURLPath = profileEntity.imageUrl;
//        model.nickname = profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
//    }
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.model = model;
    return cell;
}

#pragma mark - Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:section]];
    [contentView addSubview:label];
    return contentView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    EaseUserModel *model = [[self.dataArray objectAtIndex:section] objectAtIndex:row];
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    if (loginUsername && loginUsername.length > 0) {
        if ([loginUsername isEqualToString:model.buddy]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:model.buddy conversationType:EMConversationTypeChat];
    chatController.title = model.nickname.length > 0 ? model.nickname : model.buddy;
    chatController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:chatController animated:YES];
    
}


#pragma mark - EaseUserCellDelegate

- (void)cellLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row >= 1) {
        // 群组，聊天室
        return;
    }
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    EaseUserModel *model = [[self.dataArray objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
    if ([model.buddy isEqualToString:loginUsername])
    {
        return;
    }
    
    _currentLongPressIndex = indexPath.row;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"friend.block", @"join the blacklist") otherButtonTitles:nil, nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
