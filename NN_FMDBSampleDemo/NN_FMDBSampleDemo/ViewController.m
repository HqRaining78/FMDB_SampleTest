//
//  ViewController.m
//  NN_FMDBSampleDemo
//
//  Created by IOF－IOS2 on 15/12/1.
//  Copyright © 2015年 NN_逝去. All rights reserved.
//

#import "ViewController.h"
#import "NNFMDBTool.h"
#import "LVModal.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *modalsArrM;

@property (weak, nonatomic) IBOutlet UITextField *card_idTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@end

@implementation ViewController

- (NSMutableArray *)modalsArrM {
    if (!_modalsArrM) {
        _modalsArrM = [[NSMutableArray alloc] init];
    }
    return _modalsArrM;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    
    [[NNFMDBTool sharedInstance] execSqlInFmdb:@"tmp" dbFileName:@"test.sqlite" dbHandler:^(FMDatabase *nn_db) {
        NSString *cSql = @"CREATE TABLE IF NOT EXISTS TEST (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age TEXT NOT NULL, ID_No TEXT NOT NULL)";
        BOOL res = [nn_db executeUpdate:cSql];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"succ to creating db table");
        }
    }];
}

- (IBAction)insertData:(id)sender {
    [[NNFMDBTool sharedInstance] execSqlInFmdb:@"tmp" dbFileName:@"test.sqlite" dbHandler:^(FMDatabase *nn_db) {
        LVModal *modal = [LVModal modalWith:_nickNameTextField.text age:_ageTextField.text.intValue no:_card_idTextField.text.intValue];

        NSString * sql = @"insert into TEST (name, age, ID_No) values(?, ?, ?)";
        BOOL res = [nn_db executeUpdate:sql, _nickNameTextField.text, _ageTextField.text, _card_idTextField.text];
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
            [self.modalsArrM addObject:modal];
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)updateData:(id)sender {
    if (_nickNameTextField.text) {
        [[NNFMDBTool sharedInstance] execSqlInFmdb:@"tmp" dbFileName:@"test.sqlite" dbHandler:^(FMDatabase *nn_db) {
             NSString *uSql = @"UPDATE TEST SET name = ? WHERE ID_No = ?";
            BOOL res = [nn_db executeUpdate:uSql,_nickNameTextField.text, _card_idTextField.text];
            if (!res) {
                NSLog(@"error to UPDATE data");
            } else {
                NSLog(@"succ to UPDATE data");
                [self queryData:nil];
            }
        }];
    }
    
}

- (IBAction)deleteData:(id)sender {
    if (_card_idTextField.text) {
     
        [[NNFMDBTool sharedInstance] execSqlInFmdb:@"tmp" dbFileName:@"test.sqlite" dbHandler:^(FMDatabase *nn_db) {
            NSString *dSql = @"DELETE FROM TEST WHERE ID_No = ?";
            BOOL res = [nn_db executeUpdate:dSql, _card_idTextField.text];
            if (!res) {
                NSLog(@"error to DELETE data");
            } else {
                NSLog(@"succ to DELETE data");
                [self queryData:nil];
            }
        }];
    }
}


- (IBAction)queryData:(id)sender {
    [[NNFMDBTool sharedInstance] execSqlInFmdb:@"tmp" dbFileName:@"test.sqlite" dbHandler:^(FMDatabase *nn_db) {
        [self.modalsArrM removeAllObjects];

        NSMutableArray *arrM = [NSMutableArray array];
        NSString *qSql = @"SELECT * FROM TEST";
        FMResultSet *set = [nn_db executeQuery:qSql];
        

        while ([set next]) {
            
            NSString *name = [set stringForColumn:@"name"];
            NSString *age = [set stringForColumn:@"age"];
            NSString *ID_No = [set stringForColumn:@"ID_No"];
            
            LVModal *modal = [LVModal modalWith:name age:age.intValue no:ID_No.intValue];
            [arrM addObject:modal];
        }
        [self.modalsArrM addObjectsFromArray:arrM];
        
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.modalsArrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    LVModal *modal = self.modalsArrM[indexPath.row];
    cell.textLabel.text = modal.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd", modal.ID_No];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
